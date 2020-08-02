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
    final query = await Firestore.instance
        .collection('users')
        .document(this.owner_id)
        .collection('reminders')
        .getDocuments();
    final List<DocumentSnapshot> docs = query.documents;
    this._reminders = docs.map(
      (doc) => Reminder.fromFirebase(doc.data, this.owner_id)
    ).toList();
   }

  Future<void> addReminder(Reminder newReminder) async {
    await Firestore.instance
        .collection('users')
        .document(this.owner_id)
        .collection('reminders')
        .document()
        .setData({
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
}

