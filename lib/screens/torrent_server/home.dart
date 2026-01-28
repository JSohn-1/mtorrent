import 'package:flutter/material.dart';
import '../../helpers/decoration.dart';

import '../../servers/torrent_server_base.dart';

class TorrentServerHomeScreen extends StatelessWidget {

  const TorrentServerHomeScreen({super.key, required this.server});
  final TorrentServerBase server;

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: Column(children: [Text('Hello World!')]),
      ),
    );
}
