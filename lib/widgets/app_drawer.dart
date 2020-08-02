import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/reminders_screen.dart';
import '../screens/notifiers_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Menu'),
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Reminders'),
              onTap: () {
                Navigator.pushNamed(context, RemindersScreen.routeName);
              }),
          Divider(),
          ListTile(
          leading: Icon(Icons.assignment),
          title: Text('Notifications'),
          onTap: () {
            Navigator.pushNamed(context, NotifiersScreen.routeName);
          }),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}
