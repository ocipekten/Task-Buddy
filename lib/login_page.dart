import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskbuddy/fire_auth.dart';
import 'package:taskbuddy/registration_page.dart';
import 'package:taskbuddy/themes.dart';
import 'package:taskbuddy/validator.dart';
import 'data_structures.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static String routeName = 'loginPage';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();

  final FocusNode _focusEmail = FocusNode();
  final FocusNode _focusPassword = FocusNode();

  bool _isProcessing = false;
  String _errorText = "";

  // @override
  // void initState() {
  //   //_checkUser();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return getLoginBody();
  }

  Widget getLoginBody(){
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        body: FutureBuilder(
            future: _initializeFirebase(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: const AssetImage('logo.png'),
                          width: 80.0,
                          height: 80.0,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(
                          height: 35.0,
                        ),
                        TextFormField(
                          controller: _emailTextController,
                          focusNode: _focusEmail,
                          // validator: (value) {
                          //   Validator.validateEmail(email: value!);
                          // },
                          validator: (value) => Validator.validateEmail(
                            email: value!,
                          ),
                          obscureText: false,
                          decoration: getInputDecoration('Email'),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        TextFormField(
                          controller: _passwordTextController,
                          focusNode: _focusPassword,
                          validator: (value) {
                            Validator.validatePassword(password: value!);
                          },
                          obscureText: true,
                          decoration: getInputDecoration('Password'),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        getLoginButton(),
                        const SizedBox(
                          height: 25,
                        ),
                        getErrorText(),
                        const SizedBox(
                          height: 25,
                        ),
                        getSignUpText(),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  Widget getLoginButton() {
    return _isProcessing
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: () async {
              setState(() {
                _isProcessing = true;
                _errorText = "";
              });

              _focusEmail.unfocus();
              _focusPassword.unfocus();

              if (_formKey.currentState!.validate()) {
                User? user = await FireAuth.signInUsingEmailPassword(email: _emailTextController.text, password: _passwordTextController.text, context: context);
                if (user != null){
                  _checkUser();
                }
                setState(() {
                  _isProcessing = false;
                  _errorText = "";
                });
              }else{

              setState(() {
                _isProcessing = false;
                _errorText = "No User Found with this Email/Password!";
              });}
            },
            child: const Text('Login'),
          );
  }

  Widget getSignUpText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Don\'t have an account? Sign up '),
        GestureDetector(
            child: const Text(
              'here',
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegistrationPage()));
            }),
        const Text('.'),
      ],
    );
  }

  Widget getErrorText() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
        [
            Text(_errorText, style: TextStyle(color: Colors.red))
        ],
      );
  }

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  void _checkUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    List<Person> members = [];
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        print('No user found!');
        return;
      } else {
        print('User found!');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => HomePage(
                  user: user,
                )),
            ModalRoute.withName(HomePage.routeName));
      }
    });
  }
}
