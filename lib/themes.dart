import 'package:flutter/material.dart';

ThemeData getThemeData() {
  return ThemeData(
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.amber,

      ));
}

InputDecoration getInputDecoration(String label){
  return InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
    errorBorder: UnderlineInputBorder(
      borderRadius: BorderRadius.circular(6.0),
      borderSide: const BorderSide(
        color: Colors.red,
      ),
    ),
  );
}

TextStyle getTextStyle(){
  return const TextStyle(
    color: Colors.black,
    fontSize: 20,
  );
}