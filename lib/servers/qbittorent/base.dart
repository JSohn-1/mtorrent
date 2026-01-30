import 'dart:async';

import 'package:http/http.dart' as http;
import '../../helpers/constants.dart';
import '../models/torrent.dart';

import 'network.dart';
import '../models/server.dart';
import '../torrent_server_base.dart';

class QBittorrentServer implements TorrentServerBase {
  QBittorrentServer({
    this.url,
    this.label,
    this.username,
    this.password,
    http.Client? httpClient,
    this.isTestMode = false,
  }) : client = httpClient ?? http.Client() {
    torrentStreamController = StreamController<List<Torrent>>.broadcast();
    connectionStatusStreamController = StreamController<bool>.broadcast();

    network = Network(
      Server(
        url: url ?? '',
        username: username ?? '',
        password: password ?? '',
      ),
      client!,
    );

    _init();
  }

  static Future<bool> isValidServer(Server server) async =>
      Network.isValid(server);

  @override
  Future<String?> isValidCredentials() async => network.isValidCredentials();

  @override
  final String? url;
  @override
  final String? label;
  @override
  final String? username;
  @override
  final String? password;
  final bool isTestMode;

  @override
  late final StreamController<List<Torrent>> torrentStreamController;

  @override
  late final StreamController<bool> connectionStatusStreamController;

  @override
  final http.Client? client;

  late final Network network;

  Future<void> _init() async {
    if (isTestMode) {
      return;
    }

    try {
      await network.authenticate();

      unawaited(_periodicTorrentFetch());
      unawaited(_periodicConnectionCheck());

      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      rethrow;
    }
  }

  Future<void> torrentFetch() async {
    final torrents = await network.fetchTorrents();
    torrentStreamController.add(torrents);
  }

  Future<void> connectionCheck() async {
    try {
      final isConnected = await network.applicationVersion(
        timeout: const Duration(seconds: 2),
      );
      connectionStatusStreamController.add(isConnected.isNotEmpty);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      connectionStatusStreamController.add(false);
    }
  }

  Future<void> _periodicTorrentFetch() async {
    while (true) {
      try {
        await torrentFetch();
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        continue;
      }
      await Future<void>.delayed(refreshInterval);
    }
  }

  Future<void> _periodicConnectionCheck() async {
    while (true) {
      await connectionCheck();
      await Future<void>.delayed(refreshInterval);
    }
  }
}
