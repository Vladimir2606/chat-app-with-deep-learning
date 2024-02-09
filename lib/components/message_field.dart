import 'package:flutter/material.dart';

class MessageField extends StatelessWidget {
  final String message;
  final Color color;
  final BorderRadiusGeometry borderRadius;
  const MessageField(
      {super.key,
      required this.message,
      required this.color,
      required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: borderRadius, color: color),
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
