// ignore_for_file: avoid_print

import 'dart:math';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/encryption/encryption_service.dart';
import 'package:chatapp/services/encryption/key_gen.dart';
import 'package:chatapp/services/encryption/secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChildController extends GetxController {
  final childFullnameController = TextEditingController();
}

class ParentController extends GetxController {
  final parentFullnameController = TextEditingController();
}

class EmailController extends GetxController {
  final emailController = TextEditingController();
}

class PasswordController extends GetxController {
  final passwordController = TextEditingController();
  final repeatedPasswordController = TextEditingController();
}

class PinController extends GetxController {
  final pinController = TextEditingController();
  final repeatedPinController = TextEditingController();
}

class RegistrationController extends GetxController {
  final childController = ChildController();
  final parentController = ParentController();
  final emailController = EmailController();
  final passwordController = PasswordController();
  final repeatedPasswordController = PasswordController();
  final pinController = PinController();
  final repeatedPinController = PinController();

  String username = "";

  void register(BuildContext context) async {
    String childFullname = childController.childFullnameController.text;
    String parentFullname = parentController.parentFullnameController.text;
    String email = emailController.emailController.text;
    String password = passwordController.passwordController.text;
    String pin = pinController.pinController.text;

    createUsername(childFullname);

    final authService = Get.find<AuthService>();
    try {
      await authService.registerWithEmailAndPassword(
          username, email, password, childFullname, parentFullname, pin);

      final keyPair = generateRSAKeyPair(secureRandom());
      final publicKey = keyPair.publicKey;
      final privateKey = keyPair.privateKey;

      String encodedPublicKey = encodePublicKeyToPemPKCS1(publicKey);
      String encodedPrivateKey = encodePrivateKeyToPemPKCS1(privateKey);

      savePrivateKey(encodedPrivateKey);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(authService.currentUser!.uid)
          .update({
        'publicKey': encodedPublicKey,
      });

      // ignore: use_build_context_synchronously
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Exception: ${e.code} - ${e.message}");
    } on FirebaseException catch (e) {
      print("Firebase Exception: ${e.code} - ${e.message}");
    } on Exception catch (e) {
      print("Exception: $e");
    }
  }

  void createUsername(String childFullname) {
    String fullName = childFullname.toLowerCase();
    List<String> nameParts = fullName.split(' ');

    if (nameParts.length >= 2) {
      String firstname = nameParts[0];
      String lastname = nameParts[1];

      String firstLetterFirstname = firstname[0];
      String firstLetterLastname = lastname[0];

      Random random = Random();
      int fiveDigitNumber = random.nextInt(89999) + 10000;
      username = '$firstLetterFirstname$firstLetterLastname$fiveDigitNumber';
    } else {
      // Handle error
    }
  }
}
