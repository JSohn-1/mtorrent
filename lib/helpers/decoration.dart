import 'package:flutter/material.dart';

const backgroundColor = Color.fromARGB(255, 12, 12, 12);

final primaryDarkTheme = ThemeData.dark().copyWith(
  primaryColor: Colors.blueAccent,
  scaffoldBackgroundColor: backgroundColor,
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
);

const textFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
  floatingLabelBehavior: FloatingLabelBehavior.never,
  // border: OutlineInputBorder(
  //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
  // ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1),
    // borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
    // borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);
