import 'package:flutter/material.dart';

import './screens/homepage/home.dart';
import 'helpers/db.dart';

void main() async {
  // SUPER TEMPORARY DELETE WHEN BUILDING RELEASE
  WidgetsFlutterBinding.ensureInitialized();
  await Db().resetDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
      title: 'Flutter Demo',
      color: Color.fromARGB(255, 12, 12, 12),
      home: HomePage(),
    );
}