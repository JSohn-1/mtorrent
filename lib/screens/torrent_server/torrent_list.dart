import 'package:flutter/material.dart';

import '../../servers/models/torrent.dart';
import '../../servers/torrent_server_base.dart';
import 'torrent_info.dart';

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

        if (torrents.isEmpty) {
          return const Center(child: Text('No torrents found.'));
        }

        return ListView.builder(
          itemCount: torrents.length,
          itemBuilder: (context, index) {
            final torrent = torrents[index];
            return TorrentListItem(torrent: torrent);
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
  const TorrentListItem({required this.torrent, super.key});

  final Torrent torrent;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TorrentInfo(torrent: torrent)),
      );
    },
    child: Container(
      padding: const EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(20, 255, 255, 255),
      ),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width - 60,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name
                    Container(
                      padding: const EdgeInsets.all(4),
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: (MediaQuery.of(context).size.width - 15) / 10,
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromRGBO(255, 255, 255, 0.078),
                      ),
                      child: Text(
                        torrent.name, // Torrent name
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer(flex: 4),
                  ],
                ),
                const Spacer(),
                // Progress Bar indicator
                LinearProgressIndicator(
                  value: torrent.progress,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const Spacer(),

                Row(
                  children: [
                    SizedBox(
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Text(
                            '${torrent.sizeFormatted.value} ${torrent.sizeFormatted.unit} of ${torrent.sizeFormatted.value} ${torrent.sizeFormatted.unit} (${(torrent.progress * 100).toStringAsFixed(1)}%)',
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      size: (MediaQuery.of(context).size.width - 15) / 20,
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                    // Download Speed
                    Text(
                      torrent.downloadSpeedFormatted.value,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      torrent.downloadSpeedFormatted.unit,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Icon(
                      size: (MediaQuery.of(context).size.width - 15) / 20,
                      Icons.upload_rounded,
                      color: Colors.white,
                    ),
                    // Upload Speed
                    Text(
                      torrent.uploadSpeedFormatted.value,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      torrent.uploadSpeedFormatted.unit,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // An arrow pointing to the right to indicate that the user can click on the box to see more information
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    ),
  );
}
