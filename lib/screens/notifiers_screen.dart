import 'package:flutter/material.dart';
import '../providers/notifiers.dart';
import '../screens/new_notifier_screen.dart';
import '../widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class NotifiersScreen extends StatelessWidget {
  static const routeName = '/notifiers';

  NotifiersScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nag Me!'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Notifiers>(context, listen: false).loadNotifiers(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Consumer<Notifiers>(
              child: Center(
                child: Text('No notifiers created yet'),
              ),
              builder: (ctx, notifiers, child) => notifiers.list.length <= 0
                  ? child
                  : ListView.builder(
                      itemCount: notifiers.list.length,
                      itemBuilder: (ctx, index) => ListTile(
                        title: Text(notifiers.list[index].settings.name),
                        subtitle: Text(notifiers.list[index].settings.toDisplay()),
                      ),
                    ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(NewNotifierScreen.routeName);
        },
      ),
    );
  }
}
