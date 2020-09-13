import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nag_me_lib/nag_me.dart';

class Reminders with ChangeNotifier {
  String owner_id;
  List<Reminder> _reminders = [];

  List<Reminder> get list {
    return [..._reminders];
  }

  Future<void> loadReminders() async {
    // we fetch these from firebase!
    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(this.owner_id)
        .collection('reminders')
        .get();
    final List<DocumentSnapshot> docs = query.docs;
    this._reminders = docs.map(
      (doc) => Reminder.fromFirebase(doc.data(), doc.id, this.owner_id)
    ).toList();
   }

  Future<void> addReminder(Reminder newReminder) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(this.owner_id)
        .collection('reminders')
        .add({
      'verb': newReminder.verb,
      'reminder_text': newReminder.reminder_text,
      'regularity': newReminder.regularity,
      'start_time': {
        'hour': newReminder.start_time.hour,
        'minute': newReminder.start_time.minute
      },
      'next_time': newReminder.next_time.toString(),
    });

    _reminders.add(newReminder);
    notifyListeners();
  }

  Future<void> updateReminder(Reminder newReminder) async {
    var asMap = newReminder.toMap();
    asMap.remove('owner_id');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(this.owner_id)
        .collection('reminders')
        .doc(newReminder.id)
        .update(asMap);
  }

  Future<void> deleteReminder(Reminder toDelete) async {
     await FirebaseFirestore.instance
        .collection('users')
        .doc(this.owner_id)
        .collection('reminders')
        .doc(toDelete.id)
         .delete();
  }

  // This oughta be managed elsewhere.... but cant load mobile_service cos of config stuff
  Future<void> saveToken(String token) async {
    await FirebaseFirestore.instance
    .collection('services').doc('Mobile')
    .update({this.owner_id: token});
//    await Firestore.instance
//        .collection('users').document(this.owner_id).setData({'token': token}, merge: true);
  }
}

