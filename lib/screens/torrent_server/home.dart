import 'package:flutter/material.dart';
import '../../helpers/decoration.dart';

import '../../servers/torrent_server_base.dart';

class TorrentServerHomeScreen extends StatelessWidget {
  const TorrentServerHomeScreen({required this.server, super.key});
  final TorrentServerBase server;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Material(
      child: Container(
        decoration: const BoxDecoration(color: backgroundColor),
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: Navigator.of(context).pop,
                  ),
                  Center(child: Text(server.label!)),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
