import 'dart:async';

import 'package:http/http.dart' as http;
import 'models/torrent.dart';

abstract class TorrentServerBase {

  TorrentServerBase(
      {this.url, this.label, this.username, this.password, this.client}
  );
  static Future<bool> isValid() {
    throw UnimplementedError();
  }

  final String? url;
  final String? label;
  final String? username;
  final String? password;
  final http.Client? client;

  // ignore: close_sinks
  late final StreamController<List<Torrent>> torrentStreamController;
}
