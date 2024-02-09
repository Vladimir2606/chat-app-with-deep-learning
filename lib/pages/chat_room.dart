
import 'package:chatapp/components/message_field.dart';
import 'package:chatapp/services/chat/chat_service.dart';
import 'package:chatapp/services/encryption/encryption_service.dart';
import 'package:chatapp/services/encryption/secure_storage.dart';
import 'package:chatapp/services/model/model_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatRoom extends StatefulWidget {
  final String receiverChildsName;
  final String receiverUserId;
  const ChatRoom(
      {super.key,
      required this.receiverChildsName,
      required this.receiverUserId});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late TextClassifier _textClassifier;

  @override
  void initState() {
    super.initState();
    _textClassifier = TextClassifier();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      final prediction = _textClassifier.classify(_messageController.text);

      print(prediction[0]);
      print(prediction[1]);

      // bool isInappropriate = (prediction[1] >= prediction[0]) ? true : false;

      bool isInappropriate = false;

      print(isInappropriate);

      // ignore: dead_code
      if (isInappropriate) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Inappropriate Text'),
              content:
                  const Text('The entered text is considered inappropriate.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        _messageController.clear();
      } else {
        await _chatService.sendMessage(
            widget.receiverUserId, _messageController.text);
        _messageController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverChildsName),
        backgroundColor: const Color(0xFFFFB703),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          const SizedBox(height: 15),
          _buildMessageInput(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserId, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            throw Exception(snapshot.error);
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    return FutureBuilder<String?>(
      future: getPrivateKey(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text('Error loading private key');
          }

          String privateKey = snapshot.data!;
          return _buildMessageItemWithData(document, privateKey);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildMessageItemWithData(
      DocumentSnapshot document, String privateKey) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isCurrentUser = (data["senderId"] == _firebaseAuth.currentUser!.uid);

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: isCurrentUser
            ? const EdgeInsets.only(top: 8, bottom: 8, right: 8, left: 100)
            : const EdgeInsets.only(top: 8, bottom: 8, right: 100, left: 8),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            MessageField(
              message: isCurrentUser
                  ? decrypt(data["copiedMessage"], parsePrivateKey(privateKey)!)
                  : decrypt(data["message"], parsePrivateKey(privateKey)!),
              color: isCurrentUser ? const Color(0xFFFFB703) : Colors.grey,
              borderRadius: isCurrentUser
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(100, 100, 111, 0.2),
                blurRadius: 29,
                spreadRadius: 0,
                offset: Offset(
                  0,
                  7,
                ),
              ),
            ]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  hintText: "Enter message",
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 15),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18.0),
                  suffixIcon: IconButton(
                    icon: SvgPicture.asset(
                      "assets/send-icon.svg",
                      height: 30,
                      width: 30,
                    ),
                    onPressed: sendMessage,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
