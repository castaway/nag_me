import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nag_me_lib/nag_me.dart';
import '../providers/notifiers.dart';
import '../widgets/app_drawer.dart';

class NewNotifierScreen extends StatefulWidget {
  static const routeName = '/add_notifier';

  @override
  _NewNotifierScreenState createState() => _NewNotifierScreenState();
}

class _NewNotifierScreenState extends State<NewNotifierScreen> {
  final _thingFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
// start with daily only
  var _newNotifier = {
    'notifier': Notifier(
      owner_id: '',
      engine: null,
      settings: null,
    ),
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _newNotifier['notifier'] = Notifier(
        owner_id: ModalRoute.of(context).settings.arguments as String,
        engine: _newNotifier['notifier'].engine,
        settings: _newNotifier['notifier'].settings,
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

    print(_newNotifier);
    await Provider.of<Notifiers>(context, listen: false)
        .addNotifier(_newNotifier['notifier']);
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Notifier'),
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
                  DropdownButtonFormField(
                    items: Engine.values.map(
                      (value) {
                        return DropdownMenuItem<dynamic>(
                          value: value.toString(),
                          child: Text(value.toString()),
                        );
                      },
                    ).toList(),
                    decoration: InputDecoration(
                      labelText: 'With what?',
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please choose a system';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      Engine prev = _newNotifier['notifier'].engine;
                      Engine chosen = Engine.values
                          .firstWhere((val) => val.toString() == value);
                      // setState because this will change the engine and thus
                      // hopefully the field list..
                      // needs to update the Settings too, if it changed
                      NotifierSetting settings = prev != chosen
                          ? NotifierSetting.getInstance(chosen)
                          : _newNotifier['notifier'].settings;
                      setState(() {
                        _newNotifier['notifier'] = Notifier(
                          owner_id: _newNotifier['notifier'].owner_id,
                          engine: chosen,
                          settings: settings,
                        );
                      });
                    },
                    onSaved: (value) {
                      _newNotifier['notifier'] = Notifier(
                        owner_id: _newNotifier['notifier'].owner_id,
                        engine: _newNotifier['notifier'].engine,
                        settings: _newNotifier['notifier'].settings,
                      );
                    },
                  ),
                  // Specific fields for this particular chosen engine
                  // What does this do on initial load, when no engine chosen?
                  // Or do we default Engine to.. something?
                  if (_newNotifier['notifier'].engine != null)
                    ..._newNotifier['notifier']
                        .settings
                        .toFields(_newNotifier)
                        .map((sField) {
                      return TextFormField(
                        decoration: InputDecoration(
                          labelText: sField['label'],
                        ),
                        textInputAction: TextInputAction.next,
                        validator: sField['validator'],
                        onSaved: sField['onSaved'],
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
