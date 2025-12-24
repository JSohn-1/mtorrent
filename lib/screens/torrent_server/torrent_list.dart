import 'package:flutter/material.dart';

import 'package:mtorrent/servers/torrent_server_base.dart';

class Torrentlist extends StatefulWidget {
  final TorrentServerBase server;
  const Torrentlist({super.key, required this.server});

  @override
  State<Torrentlist> createState() => _TorrentlistState();
}

class _TorrentlistState extends State<Torrentlist> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.server.torrentStreamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final torrents = snapshot.data!;

          return ListView.builder(
            itemCount: torrents.length,
            itemBuilder: (context, index) {
              final torrent = torrents[index];
              return TorrentListItem(name: torrent.name);
            },
          );
        }

        if (snapshot.hasError) {
          showDialog(context: context, builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('Error: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
        }

        return const CircularProgressIndicator();
      });
  }
}

class TorrentListItem extends StatelessWidget {
  final String name;

  const TorrentListItem({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
    );
  }
}