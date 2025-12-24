import 'package:flutter/material.dart';
import 'package:mtorrent/helpers/decoration.dart';
import 'package:mtorrent/screens/homepage/server_list.dart';

import '../add_new.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _refreshKey = 0;

  void _refreshList() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Text('Hello, World!'),
                Expanded(child: Serverlist(key: ValueKey(_refreshKey))),
              ],
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    builder: (context) => const AddNewScreen(),
                  );
                  if (result == true) {
                    _refreshList();
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
