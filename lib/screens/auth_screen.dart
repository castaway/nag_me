import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../forms/auth_form.dart';
import '../providers/auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var isLoading = false;

  void _submitAuthForm(
      String email, String password, bool isLogin, BuildContext ctx) async {
    try {
      setState(() {
        isLoading = true;
      });
      if (isLogin) {
        await Provider.of<Auth>(context, listen: false).signin(email, password);
      } else {
        // New user
        Provider.of<Auth>(context, listen: false).signup(email, password);
        Scaffold.of(ctx).showSnackBar(SnackBar(
          content: Text('Verification email sent'),
          backgroundColor: Theme.of(context).errorColor,
        ));
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials';
      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
      ));
      setState(() {
        isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: _auth.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AuthForm(_submitAuthForm, isLoading),
                if (snapshot.hasData && !snapshot.data.isEmailVerified)
                  Center(
                    child: Card(
                      child: Column(
                        children: <Widget>[
                          Text('A verification email was sent'),
                          ButtonBar(
                            children: <Widget>[
                              RaisedButton(
                                child: const Text('Resend email'),
                                onPressed: () async {
                                  snapshot.data.sendEmailVerification();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
  }
}
