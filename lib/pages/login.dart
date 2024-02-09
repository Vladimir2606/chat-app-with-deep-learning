import 'package:chatapp/components/appbar.dart';
import 'package:chatapp/components/box_shadow.dart';
import 'package:chatapp/components/easy_button.dart';
import 'package:chatapp/components/text_field.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:io';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final username = TextEditingController();
  final password = TextEditingController();
  String errorMessage = "";
  final authService = Get.find<AuthService>();

  void signIn() async {
    try {
      await authService.signInWithEmailandPassword(
          username.text, password.text);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e.code);
    }
  }

  String passwordErrorText = "";
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFB703),
      appBar: const CustomAppBar(text: "Login", icon: Icons.arrow_back_ios_new),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
            child: Column(children: [
              Platform.isIOS
                  ? const SizedBox(height: 12)
                  : const SizedBox(height: 0),
              MyTextField(
                controller: username,
                hintText: "Username",
                obscureText: false,
                asset: "assets/name-icon.svg",
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  boxShadow: CustomBoxShadow.getBoxShadows(),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: password,
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
                          hintText: "Password",
                          hintStyle: const TextStyle(
                              color: Colors.black, fontSize: 18),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14.0),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: SvgPicture.asset(
                              "assets/password-icon.svg",
                              height: 20,
                              width: 20,
                            ),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(9.5),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                              child: isPasswordVisible
                                  ? SvgPicture.asset(
                                      "assets/passwordOn-icon.svg")
                                  : SvgPicture.asset(
                                      "assets/passwordOff-icon.svg"),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
              const SizedBox(height: 5),
              StreamBuilder<String>(
                stream: authService.errorStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        snapshot.data!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              const Spacer(),
              CustomEasyButton(onPressed: signIn, text: "Login"),
              const SizedBox(
                height: 20,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
