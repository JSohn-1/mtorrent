import 'package:flutter/material.dart';

import '../../helpers/db.dart';
import '../../servers/torrent_server_base.dart';
import '../../servers/qbittorent/base.dart';

class Serverlist extends StatelessWidget {
  const Serverlist({super.key});

  Future<List<TorrentServerBase>> _buildServerItems() async {
    final db = Db();

    final servers = await db.getServers();

    return servers.map((element) {
      if (element.type == 'BitTorrent') {
        return QBittorrentServer(
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
  Widget build(BuildContext context) => FutureBuilder(
      future: _buildServerItems(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasError) {
          return Text('Error: ${asyncSnapshot.error}');
        }

        if (asyncSnapshot.hasData) {
          final servers = asyncSnapshot.data!;

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

class ServerItem extends StatelessWidget {

  const ServerItem({super.key, required this.serverName});
  final String serverName;

  @override
  Widget build(BuildContext context) => ListTile(
      title: Text(serverName),
    );
}