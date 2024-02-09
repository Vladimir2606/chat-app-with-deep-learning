import 'package:flutter/material.dart';

class CustomBoxShadow {
  static const Color color = Color.fromRGBO(0, 0, 0, 0.16);
  static const double blurRadius = 4;
  static const double spreadRadius = 0;
  static const Offset offset = Offset(0, 1);

  static List<BoxShadow> getBoxShadows() {
    return [
      const BoxShadow(
        color: color,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: offset,
      ),
    ];
  }
}
