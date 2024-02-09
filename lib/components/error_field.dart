import 'package:flutter/material.dart';

class ErrorField extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController passwordRepeatController;
  final String passwordErrorText;
  const ErrorField(
      {super.key,
      required this.passwordController,
      required this.passwordRepeatController,
      required this.passwordErrorText});

  @override
  State<ErrorField> createState() => _ErrorFieldState();
}

class _ErrorFieldState extends State<ErrorField> {
  @override
  Widget build(BuildContext context) {
    return widget.passwordErrorText.isNotEmpty
        ? Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: const Color(0xFFF9D7D8),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade600,
                    spreadRadius: -2,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ).scale(2)
                ]),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              widget.passwordErrorText,
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  height: 1.8),
            ),
          )
        : Container();
  }
}

class PasswordValidationResult {
  bool isValid;
  List<String> errors;

  PasswordValidationResult({required this.isValid, this.errors = const []});
}
