import 'package:flutter/material.dart';
import 'package:mtorrent/helpers/decoration.dart';

import 'package:mtorrent/servers/torrent_server_base.dart';

class TorrentServerHomeScreen extends StatelessWidget {
  final TorrentServerBase server;

  const TorrentServerHomeScreen({super.key, required this.server});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: Column(children: [Text('Hello World!')]),
      ),
    );
  }
}
