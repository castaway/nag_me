import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth with ChangeNotifier {
  final _fbAuth = FirebaseAuth.instance;
  String user_id;

  bool get isAuthenticated {
    return user_id != null;
  }

  Future<void> signin(String email, String password) async {
    AuthResult authResult = await _fbAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = await Firestore.instance
        .collection('users')
        .document(authResult.user.uid)
        .get();
    if (user == null || !user.exists && authResult.user.isEmailVerified) {
      // Could store the "email" in the firestore data, but instead will only collect it for notification types
      await Firestore.instance
          .collection('users')
          .document(authResult.user.uid)
          .setData({});
    }
  }

  Future<void> signup(String email, String password) async {
    AuthResult authResult = await _fbAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    authResult.user.sendEmailVerification();
  }
}
