import 'package:flutter/material.dart';

import 'package:mtorrent/helpers/db.dart';
import 'package:mtorrent/servers/torrent_server_base.dart';
import 'package:mtorrent/servers/bittorent/main.dart';

class Serverlist extends StatelessWidget {
  const Serverlist({super.key});

  Future<List<TorrentServerBase>> _buildServerItems() async {
    final db = Db();

    final servers = await db.getServers();

    return servers.map((element) {
      if (element.type == 'BitTorrent') {
        return BittorrentServer(
          url: element.url,
          label: element.label,
          username: element.username,
          password: element.password,
        );
      }

      throw Exception('Unknown server type: ${element.type}');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _buildServerItems(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return Text('Error: ${asyncSnapshot.error}');
        }

        if (asyncSnapshot.hasData) {
          final List<TorrentServerBase> servers = asyncSnapshot.data!;

          if (servers.isEmpty) {
            return const Text('No servers added yet.');
          }

          return Material(
            child: ListView.builder(
              itemCount: servers.length,
              itemBuilder: (context, index) {
                final server = servers[index];
                return ServerItem(serverName: server.label ?? 'Unknown Server');
              },
            ),
          );
        }
        return const CircularProgressIndicator();
      }
    );
  }
}

class ServerItem extends StatelessWidget {
  final String serverName;

  const ServerItem({super.key, required this.serverName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(serverName),
    );
  }
}