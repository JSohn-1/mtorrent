import 'package:flutter/material.dart';

import './screens/homepage/home.dart';
import 'helpers/db.dart';
import 'helpers/decoration.dart';

void main() async {
  // SUPER TEMPORARY DELETE WHEN BUILDING RELEASE
  WidgetsFlutterBinding.ensureInitialized();
  await Db().resetDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flutter Demo',
    theme: primaryDarkTheme,
    home: const HomePage(),
  );
}
