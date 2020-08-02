import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/notifiers.dart';
import './providers/reminders.dart';
import './providers/auth.dart';
import './screens/auth_screen.dart';
import './screens/new_notifier_screen.dart';
import './screens/new_reminder_screen.dart';
import './screens/notifiers_screen.dart';
import './screens/reminders_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Reminders>(
          create: (_) => Reminders(),
          update: (_, auth, reminders) => reminders..owner_id = auth.user_id,
        ),
        ChangeNotifierProxyProvider<Auth, Notifiers>(
          create: (_) => Notifiers(),
          update: (_, auth, notifiers) => notifiers..owner_id = auth.user_id,
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Nag Me',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: StreamBuilder<FirebaseUser>(
              stream: FirebaseAuth.instance.onAuthStateChanged,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    child: Center(
                      child: Text('Waiting on auth...'),
                    ),
                  );
                }
                if (snapshot.hasData && snapshot.data.isEmailVerified) {
                  auth.user_id = snapshot.data.uid;
                  return RemindersScreen();
                } else {
                  return AuthScreen();
                }
              }),
          routes: {
            NewReminderScreen.routeName: (_) => NewReminderScreen(),
            NewNotifierScreen.routeName: (_) => NewNotifierScreen(),
            NotifiersScreen.routeName: (_) => NotifiersScreen(),
            RemindersScreen.routeName: (_) => RemindersScreen(),          },
        ),
      ),
    );
  }
}
