import 'dart:io';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final IconData icon;
  const CustomAppBar({super.key, required this.text, required this.icon});

  @override
  Size get preferredSize {
    return Platform.isAndroid
        ? const Size.fromHeight(
            86.0) // Hier die gewünschte Höhe für Android einstellen
        : const Size.fromHeight(kToolbarHeight);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: Platform.isAndroid ? 86 : kToolbarHeight,
      title: Text(text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: const Color(0xFFFFB703),
    );
  }
}
