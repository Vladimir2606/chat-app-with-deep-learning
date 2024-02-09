import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  User? get currentUser => _firebaseAuth.currentUser;

  @override
  void dispose() {
    _errorController.close();
    super.dispose();
  }

  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    String errorMessage;
    try {
      // check if email or password input is empty
      if (isEmailEmpty(email)) {
        errorMessage = "Please type in an email";
        _errorController.add(errorMessage);
        return Future.error(FirebaseAuthException(
            code: 'invalid-email', message: errorMessage));
      } else if (isPasswordEmpty(password)) {
        errorMessage = "Please type in an password";
        _errorController.add(errorMessage);
        return Future.error(FirebaseAuthException(
            code: 'invalid-password', message: errorMessage));
      }

      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credential":
          errorMessage = "Your username or password is wrong.";
          break;
        default:
          errorMessage = "An undefined Error happened.";
      }
      _errorController.add(errorMessage);
      return Future.error(
          FirebaseAuthException(code: e.code, message: errorMessage));
    }
  }

  bool isEmailEmpty(String email) {
    return email.trim().isEmpty;
  }

  bool isPasswordEmpty(String password) {
    return password.trim().isEmpty;
  }

  Future<UserCredential> registerWithEmailAndPassword(
      String username,
      String email,
      String password,
      String childsName,
      String parentsName,
      String pin) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '$username@chatapp.com',
        password: password,
      );

      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'username': username,
        'childsName': childsName,
        'parentsName': parentsName,
        'email': email,
        'pin': pin,
      });

      return userCredential;
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
