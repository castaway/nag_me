import 'package:flutter/material.dart';
import 'package:nag_me_lib/nag_me.dart';
import 'package:provider/provider.dart';
import '../providers/reminders.dart';
import '../widgets/app_drawer.dart';

class NewReminderScreen extends StatefulWidget {
  static const routeName = '/add_reminder';

  @override
  _NewReminderScreenState createState() => _NewReminderScreenState();
}

class _NewReminderScreenState extends State<NewReminderScreen> {
  final _thingFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
// start with daily only
  var _newReminder = Reminder(
      owner_id: '',
      verb: '',
      reminder_text: '',
      regularity: 'daily',
      start_time: NagTimeOfDay(hour: 9, minute: 0));
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _newReminder = Reminder(
        owner_id: ModalRoute.of(context).settings.arguments as String,
        verb: _newReminder.verb,
        reminder_text: _newReminder.reminder_text,
        regularity: _newReminder.regularity,
        start_time: _newReminder.start_time,
      );
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _thingFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    setState(() => _isLoading = true);
    _form.currentState.save();

    print(_newReminder);
    await Provider.of<Reminders>(context, listen: false).addReminder(_newReminder);
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // too complicated, do later
//    var regularities = ['day','week','month','year'];
    var hours = List.generate(24, (index) => index + 1);
    var minutes = List.generate(60, (index) => index + 1);

    return Scaffold(
      appBar: AppBar(
        title: Text('New Reminder'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: ListView(
                children: <Widget>[
                  Text('Have you '),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Verb',
                    ),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.none,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_thingFocusNode);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a verb';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _newReminder = Reminder(
                        owner_id: _newReminder.owner_id,
                        verb: value.trim(),
                        reminder_text: _newReminder.reminder_text,
                        regularity: _newReminder.regularity,
                        start_time: _newReminder.start_time,
                      );
                    },
                  ),
                  Text(' your '),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Reminder text',
                    ),
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus();
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a reminder text';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _newReminder = Reminder(
                        owner_id: _newReminder.owner_id,
                        verb: _newReminder.verb,
                        reminder_text: value,
                        regularity: _newReminder.regularity,
                        start_time: _newReminder.start_time,
                      );
                    },
                  ),
                  Text(' every day at: '),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField(
                          items: hours.map(
                            (value) {
                              return DropdownMenuItem<dynamic>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            },
                          ).toList(),
                          decoration: InputDecoration(
                            labelText: 'Hour',
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please choose an hour';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _newReminder = Reminder(
                              owner_id: _newReminder.owner_id,
                              verb: _newReminder.verb,
                              reminder_text: _newReminder.reminder_text,
                              regularity: _newReminder.regularity,
                              start_time: NagTimeOfDay(
                                  hour: value,
                                  minute: _newReminder.start_time.minute),
                            );
                          },
                          onSaved: (value) {
                            _newReminder = Reminder(
                              owner_id: _newReminder.owner_id,
                              verb: _newReminder.verb,
                              reminder_text: _newReminder.reminder_text,
                              regularity: _newReminder.regularity,
                              start_time: NagTimeOfDay(
                                  hour: value,
                                  minute: _newReminder.start_time.minute),
                            );
                          },
                        ),
                      ),
                      Text(':'),
                      Expanded(
                        child: DropdownButtonFormField(
                          items: minutes.map(
                            (value) {
                              return DropdownMenuItem<dynamic>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            },
                          ).toList(),
                          decoration: InputDecoration(
                            labelText: 'Minute',
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please choose a minute';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _newReminder = Reminder(
                              owner_id: _newReminder.owner_id,
                              verb: _newReminder.verb,
                              reminder_text: _newReminder.reminder_text,
                              regularity: _newReminder.regularity,
                              start_time: NagTimeOfDay(
                                  hour: _newReminder.start_time.hour,
                                  minute: value),
                            );
                          },
                          onSaved: (value) {
                            _newReminder = Reminder(
                              owner_id: _newReminder.owner_id,
                              verb: _newReminder.verb,
                              reminder_text: _newReminder.reminder_text,
                              regularity: _newReminder.regularity,
                              start_time: NagTimeOfDay(
                                  hour: _newReminder.start_time.hour,
                                  minute: value),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
