import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? prefixIcon;
  final VoidCallback? onTapSuffix;
  final String passwordErrorText;
  final Function(String) onErrorTextUpdated;

  const PasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.onTapSuffix,
    required this.passwordErrorText,
    required this.onErrorTextUpdated,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isPasswordVisible = false;
  String errorText = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade600,
            spreadRadius: -2,
            blurRadius: 5,
            offset: const Offset(0, 0),
          ).scale(2)
        ],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(
          controller: widget.controller,
          obscureText: !isPasswordVisible,
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
            hintText: widget.hintText,
            hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
            contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: SvgPicture.asset(
                      widget.prefixIcon!,
                      height: 20,
                      width: 20,
                    ),
                  )
                : null,
            suffixIcon: Padding(
              padding: const EdgeInsets.all(9.5),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
                child: isPasswordVisible
                    ? SvgPicture.asset("assets/passwordOn-icon.svg")
                    : SvgPicture.asset("assets/passwordOff-icon.svg"),
              ),
            ),
            errorText: widget.passwordErrorText.isNotEmpty
                ? widget.passwordErrorText
                : null,
          ),
        ),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    updateErrorText();
  }

  void updateErrorText() {
    if (widget.passwordErrorText.isNotEmpty) {
      setState(() {
        errorText = widget.passwordErrorText;
      });
      widget.onErrorTextUpdated(errorText);
    }
  }
}
