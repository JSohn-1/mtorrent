import 'dart:async';

import 'package:http/http.dart' as http;
import 'models/server.dart';
import 'models/torrent.dart';

enum ServerState { connected, disconnected, error }

abstract class TorrentServerBase {
  TorrentServerBase({
    this.url,
    this.label,
    this.username,
    this.password,
    this.client,
  });

  static Future<bool> isValidServer(Server server) {
    throw UnimplementedError();
  }

  Future<String?> isValidCredentials() {
    throw UnimplementedError();
  }

  final String? url;
  final String? label;
  final String? username;
  final String? password;
  final http.Client? client;
  // Concrete controllers provided by the base class; subclasses can reuse them.
  // ignore: close_sinks
  final StreamController<List<Torrent>> torrentStreamController =
      StreamController<List<Torrent>>.broadcast();
  // ignore: close_sinks
  final StreamController<ServerState> connectionStatusStreamController =
      StreamController<ServerState>.broadcast();

  void dispose() {
    torrentStreamController.close();
    connectionStatusStreamController.close();
  }
}
