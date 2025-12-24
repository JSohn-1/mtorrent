
import 'package:flutter/material.dart';

const backgroundColor = Color.fromARGB(255, 12, 12, 12);

const textFieldDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  floatingLabelBehavior: FloatingLabelBehavior.never,
  // border: OutlineInputBorder(
  //   borderRadius: BorderRadius.all(Radius.circular(32.0)),
  // ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
    // borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
    // borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);