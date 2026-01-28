import 'package:flutter/material.dart';
import '../../helpers/decoration.dart';

import '../../servers/torrent_server_base.dart';

class TorrentServerHomeScreen extends StatelessWidget {

  const TorrentServerHomeScreen({required this.server, super.key});
  final TorrentServerBase server;

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Container(
        decoration: const BoxDecoration(color: backgroundColor),
        child: const Column(children: [Text('Hello World!')]),
      ),
    );
}
