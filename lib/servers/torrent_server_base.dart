import 'dart:async';

import 'package:mtorrent/servers/models/torrent.dart';

abstract class TorrentServerBase {
  static Future<bool> isValid() {
    throw UnimplementedError();
  }

  final String? url;
  final String? label;
  final String? username;
  final String? password;

  late final StreamController<List<Torrent>> torrentStreamController;

  TorrentServerBase(
      {this.url, this.label, this.username, this.password}
  );
}