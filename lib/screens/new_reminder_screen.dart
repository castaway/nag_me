import 'package:flutter/material.dart';
import 'package:nag_me_lib/nag_me.dart';
import 'package:provider/provider.dart';
import '../providers/reminders.dart';
import '../widgets/app_drawer.dart';

class EditReminderScreen extends StatefulWidget {
  static const routeName = '/add_reminder';

  @override
  _EditReminderScreenState createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _thingFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
// start with daily only
  var _editedReminder = Reminder(
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
      final reminderArg = ModalRoute.of(context).settings.arguments as Reminder;
      _editedReminder = Reminder(
        owner_id: reminderArg.owner_id,
        id: reminderArg.id,
        verb: reminderArg.verb,
        reminder_text: reminderArg.reminder_text,
        regularity: reminderArg.regularity,
        start_time: reminderArg.start_time,
        next_time: reminderArg.next_time,
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

    print(_editedReminder);
    if(_editedReminder.id != null) {
      await Provider.of<Reminders>(context, listen: false)
          .updateReminder(_editedReminder);
    } else {
      await Provider.of<Reminders>(context, listen: false).addReminder(
          _editedReminder);
    }
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
        title: Text('Edit Reminder'),
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
                    initialValue: _editedReminder.verb,
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
                      _editedReminder = Reminder(
                        id: _editedReminder.id,
                        owner_id: _editedReminder.owner_id,
                        verb: value.trim(),
                        reminder_text: _editedReminder.reminder_text,
                        regularity: _editedReminder.regularity,
                        start_time: _editedReminder.start_time,
                      );
                    },
                  ),
                  Text(' your '),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Reminder text',
                    ),
                    initialValue: _editedReminder.reminder_text,
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
                      _editedReminder = Reminder(
                        owner_id: _editedReminder.owner_id,
                        id: _editedReminder.id,
                        verb: _editedReminder.verb,
                        reminder_text: value,
                        regularity: _editedReminder.regularity,
                        start_time: _editedReminder.start_time,
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
                          value: _editedReminder.start_time.hour,
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
                            _editedReminder = Reminder(
                              owner_id: _editedReminder.owner_id,
                              id: _editedReminder.id,
                              verb: _editedReminder.verb,
                              reminder_text: _editedReminder.reminder_text,
                              regularity: _editedReminder.regularity,
                              start_time: NagTimeOfDay(
                                  hour: value,
                                  minute: _editedReminder.start_time.minute),
                            );
                          },
                          onSaved: (value) {
                            _editedReminder = Reminder(
                              owner_id: _editedReminder.owner_id,
                              id: _editedReminder.id,
                              verb: _editedReminder.verb,
                              reminder_text: _editedReminder.reminder_text,
                              regularity: _editedReminder.regularity,
                              start_time: NagTimeOfDay(
                                  hour: value,
                                  minute: _editedReminder.start_time.minute),
                            );
                          },
                        ),
                      ),
                      Text(':'),
                      Expanded(
                        child: DropdownButtonFormField(
                          value: _editedReminder.start_time.hour,
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
                            _editedReminder = Reminder(
                              owner_id: _editedReminder.owner_id,
                              id: _editedReminder.id,
                              verb: _editedReminder.verb,
                              reminder_text: _editedReminder.reminder_text,
                              regularity: _editedReminder.regularity,
                              start_time: NagTimeOfDay(
                                  hour: _editedReminder.start_time.hour,
                                  minute: value),
                            );
                          },
                          onSaved: (value) {
                            _editedReminder = Reminder(
                              owner_id: _editedReminder.owner_id,
                              id: _editedReminder.id,
                              verb: _editedReminder.verb,
                              reminder_text: _editedReminder.reminder_text,
                              regularity: _editedReminder.regularity,
                              start_time: NagTimeOfDay(
                                  hour: _editedReminder.start_time.hour,
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
