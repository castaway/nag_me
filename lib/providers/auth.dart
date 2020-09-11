import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth with ChangeNotifier {
  final _fbAuth = FirebaseAuth.instance;
  String user_id;

//  String get userId => _fbAuth.currentUser != null ? _fbAuth.currentUser.uid : null;

  bool get isAuthenticated {
    return _fbAuth.currentUser != null;
  }

  Future<void> signin(String email, String password) async {
    UserCredential authResult = await _fbAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = await FirebaseFirestore.instance
        .collection('users')
        .doc(authResult.user.uid)
        .get();
    if (user == null || !user.exists && authResult.user.emailVerified) {
      // Could store the "email" in the firestore data, but instead will only collect it for notification types
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user.uid)
          .set({});
    }
  }

  Future<void> signup(String email, String password) async {
    UserCredential authResult = await _fbAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    authResult.user.sendEmailVerification();
  }
}
