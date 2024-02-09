import 'package:chatapp/components/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB703),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset('assets/chat-icon.svg'),
              const Text(
                "KidsChat",
                style: TextStyle(
                    fontFamily: "IBM Plex Mono",
                    fontSize: 64,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 50),
              Button(
                  onTap: () {
                    Get.toNamed('/child');
                  },
                  text: "Register"),
              const SizedBox(height: 25),
              Button(
                  onTap: () {
                    Get.toNamed('/login');
                  },
                  text: "Login"),
              const SizedBox(height: 50),
            ]),
          ),
        ),
      ),
    );
  }
}
