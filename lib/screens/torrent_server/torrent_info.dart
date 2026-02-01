import 'package:flutter/material.dart';

import '../../servers/models/torrent.dart';

class TorrentInfo extends StatelessWidget {
  final Torrent torrent;

  const TorrentInfo({Key? key, required this.torrent}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Torrent Info - ${torrent.id}')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Torrent ID: ${torrent.id}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${torrent.status}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Size: ${torrent.sizeBytes} bytes',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Download Speed: ${torrent.downloadSpeedBytesPerSec} bytes/sec',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload Speed: ${torrent.uploadSpeedBytesPerSec} bytes/sec',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Downloaded: ${torrent.downloadedBytes} bytes',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    ),
  );
}
