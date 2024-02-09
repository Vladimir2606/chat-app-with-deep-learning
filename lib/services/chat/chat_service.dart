import 'package:chatapp/model/message.dart';
import 'package:chatapp/services/encryption/encryption_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    String? publicKeyReceiver = await getPublicKey(receiverId);
    String? publicKeySender = await getPublicKey(currentUserId);

    RSAPublicKey? decodedKey = parsePublicKey(publicKeyReceiver!);
    String encryptMessage = encrypt(message, decodedKey!);

    RSAPublicKey? decodedKeySender = parsePublicKey(publicKeySender!);
    String encryptMessageSender = encrypt(message, decodedKeySender!);

    Message newMessage = Message(
        senderId: currentUserId,
        receiverId: receiverId,
        message: encryptMessage,
        copiedMessage: encryptMessageSender,
        timestamp: timestamp);

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firebaseFirestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    return _firebaseFirestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<String?> getPublicKey(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firebaseFirestore.collection('users').doc(id).get();
      if (userDoc.exists) {
        return userDoc.get('publicKey');
      } else {
        return null;
      }
    } catch (error) {
      print('Error retrieving public key: $error');
      return null;
    }
  }
}
