import 'package:flutter/material.dart';
import 'registration_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskBuddy',
      theme: getThemeData(),
      home: const LoginPage(),
    );
  }
}