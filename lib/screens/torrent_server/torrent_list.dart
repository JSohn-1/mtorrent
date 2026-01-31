import 'package:flutter/material.dart';

import '../../servers/torrent_server_base.dart';

class Torrentlist extends StatefulWidget {
  const Torrentlist({required this.server, super.key});
  final TorrentServerBase server;

  @override
  State<Torrentlist> createState() => _TorrentlistState();
}

class _TorrentlistState extends State<Torrentlist> {
  @override
  Widget build(BuildContext context) => StreamBuilder(
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
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
          ),
        );
      }

      return const CircularProgressIndicator();
    },
  );
}

class TorrentListItem extends StatelessWidget {
  const TorrentListItem({required this.name, super.key});
  final String name;

  @override
  Widget build(BuildContext context) => ListTile(title: Text(name));
}
