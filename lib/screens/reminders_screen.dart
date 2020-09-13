import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminders.dart';
import '../screens/new_reminder_screen.dart';
import '../widgets/app_drawer.dart';

class RemindersScreen extends StatefulWidget {
  static const routeName = '/reminders';

  @override
  _RemindersScreenState createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  @override
  void initState() {
    final fcm = FirebaseMessaging();
    final reminders = Provider.of<Reminders>(context, listen: false);
    fcm.requestNotificationPermissions();
    fcm.getToken().then((token) => reminders.saveToken(token));
    fcm.configure(onMessage: (msg) {
      print('onMessage ' + msg.toString());
      return;
    }, onLaunch: (msg) {
      print('onLaunch ' + msg.toString());
      return;
    }, onResume: (msg) {
      print('onResume :' + msg.toString());
      return;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final scaffold = Scaffold.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Nag Me!'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future:
              Provider.of<Reminders>(context, listen: false).loadReminders(),
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return Consumer<Reminders>(
                child: Center(
                  child: Text('No reminders created yet'),
                ),
                builder: (ctx, reminders, child) => reminders.list.length <= 0
                    ? child
                    : ListView.builder(
                        itemCount: reminders.list.length,
                        itemBuilder: (ctx, index) => Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                  'Have you ${reminders.list[index].verb} your ${reminders.list[index].reminder_text}?'),
                              subtitle: Text(
                                  'Next run: ${reminders.list[index].next_time.toString()}'),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                            EditReminderScreen.routeName,
                                            arguments: reminders.list[index]);
                                      },
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () async {
                                        try {
                                          await Provider.of<Reminders>(context,
                                                  listen: false)
                                              .deleteReminder(
                                                  reminders.list[index]);
                                        } catch (error) {
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Deleting failed!',
                                                  textAlign: TextAlign.center),
                                            ),
                                          );
                                        }
                                      },
                                      color: Theme.of(context).errorColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(EditReminderScreen.routeName);
        },
      ),
    );
  }
}
