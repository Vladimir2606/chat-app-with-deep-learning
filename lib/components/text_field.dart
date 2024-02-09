import 'package:chatapp/components/box_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? asset;
  final VoidCallback? onTapSuffix;
  final Widget? suffixIcon;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      this.asset,
      this.suffixIcon,
      this.onTapSuffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: CustomBoxShadow.getBoxShadows(),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
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
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black, fontSize: 18),
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
          prefixIcon: asset != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: SvgPicture.asset(
                    asset!,
                    height: 20,
                    width: 20,
                  ),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? Padding(padding: const EdgeInsets.all(9.5), child: suffixIcon)
              : null,
        ),
      ),
    );
  }
}
