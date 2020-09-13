import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialisation = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
     return FutureBuilder(
         future: _initialisation,
         builder: (context, snapshot) {
           if (snapshot.hasError) {
             print('Something went wrong: ${snapshot.error}');
             return Text('Error!');
           }
           if (snapshot.connectionState == ConnectionState.waiting) {
             return Text('Loading...');
           }
           return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => Auth(),
              ),
              ChangeNotifierProxyProvider<Auth, Reminders>(
                create: (_) => Reminders(),
                update: (_, auth, reminders) =>
                    reminders..owner_id = auth.user_id,
              ),
              ChangeNotifierProxyProvider<Auth, Notifiers>(
                create: (_) => Notifiers(),
                update: (_, auth, notifiers) =>
                    notifiers..owner_id = auth.user_id,
              ),
            ],
            child: Consumer<Auth>(
              builder: (ctx, auth, _) => MaterialApp(
                title: 'Nag Me',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                home: StreamBuilder<User>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          child: Center(
                            child: Text('Waiting on auth...'),
                          ),
                        );
                      }
                      if (snapshot.hasData && snapshot.data.emailVerified) {
                        auth.user_id = snapshot.data.uid;
                        return RemindersScreen();
                      } else {
                        return AuthScreen();
                      }
                    }),
                routes: {
                  EditReminderScreen.routeName: (_) => EditReminderScreen(),
                  NewNotifierScreen.routeName: (_) => NewNotifierScreen(),
                  NotifiersScreen.routeName: (_) => NotifiersScreen(),
                  RemindersScreen.routeName: (_) => RemindersScreen(),
                },
              ),
            ),
          );
        });
  }
}
