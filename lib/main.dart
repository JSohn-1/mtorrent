import 'package:flutter/material.dart';

import './screens/homepage/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      color: const Color.fromARGB(255, 12, 12, 12),
      home: const HomePage(),
    );
  }
}