import 'package:flutter/material.dart';

import '../../helpers/db.dart';
import '../../helpers/decoration.dart';
import '../../servers/torrent_server_base.dart';
import '../../servers/qbittorent/base.dart';

class Serverlist extends StatelessWidget {
  const Serverlist({super.key});

  Future<List<TorrentServerBase>> _buildServerItems() async {
    final db = Db();

    final servers = await db.getServers();

    return servers.map((element) {
      if (element.type == 'qBittorrent') {
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
          color: backgroundColor,
          child: ListView.builder(
            itemCount: servers.length,
            itemBuilder: (context, index) {
              final server = servers[index];
              return ServerItem(server: server);
            },
          ),
        );
      }
      return const CircularProgressIndicator();
    },
  );
}

class ServerItem extends StatelessWidget {
  const ServerItem({required this.server, super.key});
  final TorrentServerBase server;

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        ConnectionStateIndicator(server: server),
        const Padding(padding: EdgeInsets.all(10)),
        Text(
          server.label ?? 'Unknown Server',
          style: const TextStyle(color: Colors.white),
        ),
        const Spacer(),
        const Icon(Icons.arrow_forward_ios),
      ],
    ),
  );
}

class ConnectionStateIndicator extends StatefulWidget {
  const ConnectionStateIndicator({required this.server, super.key});
  final TorrentServerBase server;

  @override
  State<ConnectionStateIndicator> createState() =>
      _ConnectionStateIndicatorState();
}

class _ConnectionStateIndicatorState extends State<ConnectionStateIndicator> {
  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: widget.server.connectionStatusStreamController.stream,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: snapshot.data! ? Colors.green : Colors.red,
          ),
          width: 16,
          height: 16,
        );
      }

      return const CircularProgressIndicator();
    },
  );
}
