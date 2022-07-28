import 'package:crypto_admin/Components/rounded_button.dart';
import 'package:crypto_admin/screens/Banner/admin_panel_screen.dart';
import 'package:crypto_admin/screens/Utilities/pop_up_widget.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:crypto_admin/constants.dart';
import 'package:crypto_admin/ChatScreens/type_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class RegistrationScreen extends StatefulWidget {
  static String id = 'Register_Screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  var email;
  var password;
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                    //Do something with the user input.
                  },
                  decoration: KTextFieldFecoration.copyWith(
                      hintText: 'Enter your email')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    password = value;
                  },
                  decoration: KTextFieldFecoration.copyWith(
                      hintText: 'Enter your password')),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                colour: Colors.blueAccent,
                Onpressed: () async {
                  devtools.log('$email  $password');
                  try {
                    setState(() {
                      showSpinner = true;
                    });
                    final newUser = _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );

                    if (newUser != null) {
                      Navigator.popAndPushNamed(context, AdminPanelScreen.id);
                    }
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'weak-password') {
                      devtools.log('Error: weak password');
                      await showErrorDialog(context, 'Weak Password');
                    } else if (e.code == 'emial-already-in-use') {
                      await showErrorDialog(
                          context, 'This email adress is already registed');
                    }
                  } catch (e) {
                    await showErrorDialog(context, 'Error: $e');
                  }
                  setState(() {
                    showSpinner = false;
                  });
                },
                title: 'Register',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
