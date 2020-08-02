import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nag_me_lib/nag_me.dart';

class Notifiers with ChangeNotifier {
  String owner_id;

  List<Notifier> _notifiers = [];

  List<Notifier> get list {
    return [..._notifiers];
  }

  Future<void> loadNotifiers() async {
    // we fetch these from firebase!
    final query = await Firestore.instance
        .collection('users')
        .document(this.owner_id)
        .collection('notifiers')
        .getDocuments();
    final List<DocumentSnapshot> docs = query.documents;
    this._notifiers = docs.map((doc) {
      Engine chosen = Engine.values.firstWhere((val) =>
          val.toString() == doc.data['engine']);
      return Notifier(
          owner_id: this.owner_id,
          engine: chosen,
          settings: NotifierSetting.getInstance(chosen, jsonDecode(doc.data['settings'])),
          last_modified: DateTime.parse(doc.data['last_modified'])
      );
    }).toList();
  }

  Future<void> addNotifier(Notifier newNotifier) async {
    await Firestore.instance
        .collection('users')
        .document(this.owner_id)
        .collection('notifiers')
        .document()
        .setData({
      'engine' : newNotifier.engine.toString(),
      'settings': newNotifier.settings.toString(),
      'last_modified': newNotifier.last_modified.toString()
    });

    _notifiers.add(newNotifier);
    notifyListeners();
  }
}

