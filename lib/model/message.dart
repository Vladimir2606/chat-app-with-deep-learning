import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final String copiedMessage;
  final Timestamp timestamp;

  Message(
      {required this.senderId,
      required this.receiverId,
      required this.message,
      required this.copiedMessage,
      required this.timestamp});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'copiedMessage': copiedMessage,
      'timestamp': timestamp,
    };
  }
}
