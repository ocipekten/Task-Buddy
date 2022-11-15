import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskbuddy/home_page.dart';
import 'fire_auth.dart';
import 'themes.dart';
import 'validator.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);
  static String routeName = 'registrationPage';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;
  String _done = "Sign up";

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(55.0),
            child: Form(
              key: _registerFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _nameTextController,
                    focusNode: _focusName,
                    validator: (value) => Validator.validateName(
                      name: value!,
                    ),
                    decoration: getInputDecoration('Name'),
                  ),
                  const SizedBox(height: 14.0),
                  TextFormField(
                    controller: _emailTextController,
                    focusNode: _focusEmail,
                    validator: (value) => Validator.validateEmail(
                      email: value!,
                    ),
                    decoration: getInputDecoration('Email'),
                  ),
                  const SizedBox(height: 14.0),
                  TextFormField(
                    controller: _passwordTextController,
                    focusNode: _focusPassword,
                    obscureText: true,
                    validator: (value) => Validator.validatePassword(
                      password: value!,
                    ),
                    decoration: getInputDecoration('Password'),
                  ),
                  const SizedBox(height: 28.0),
                  getSignInButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSignInButton() {
    return _isProcessing
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: () async {
              setState(() {
                _isProcessing = true;
              });

              _focusName.unfocus();
              _focusEmail.unfocus();
              _focusPassword.unfocus();

              if (_registerFormKey.currentState!.validate()) {
                User? user = await FireAuth.registerUsingEmailPassword(
                  name: _nameTextController.text,
                  email: _emailTextController.text,
                  password: _passwordTextController.text,
                );
                List<DocumentReference> xd = [];
                setState((){
                  _isProcessing = false;
                });

                if (user != null && !user.emailVerified) {
                  setState(() {
                    _done = "Done";
                  });

                  CollectionReference users = FirebaseFirestore.instance.collection('user');
                  await users.doc(user.uid).set({'groups': xd, 'email' : user.email});

                  // CollectionReference groups = FirebaseFirestore.instance.collection('group');
                  // await groups.add(
                  //     {
                  //       'groupName' : 'Welcome Group',
                  //       'members' : [user.email],
                  //     }
                  // ).then((value)
                  // {
                  //   xd.add(value);
                  //   FirebaseFirestore.instance.collection('group').doc(value.id).collection('Tasks').add(
                  //       {
                  //         'title' : "My First Task",
                  //         'details' : "You can add your new tasks from here!",
                  //         'points' : 10,
                  //         'creator': "Task Buddy Team",
                  //         'isDone' : false,
                  //         'whoDidIt' : "",
                  //       }
                  //   ).then((value) => value.update({'id' : value.id.toString()}).then((value)
                  //   {
                  //     DocumentReference users = FirebaseFirestore.instance.collection('user').doc(user.uid);
                  //     users.set(
                  //         {
                  //           'groups': xd,
                  //         }
                  //     );
                  //   }));
                  // });

                  await user.sendEmailVerification();
                  Navigator.of(context).pop();
                }
              }
                setState(() {
                  _isProcessing = false;
                });
            },
            child: Text(
              _done,
            ),
          );
  }
}
