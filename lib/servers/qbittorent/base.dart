import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../helpers/constants.dart';
import '../../helpers/exceptions.dart';
import '../models/torrent.dart';

import 'network.dart';
import '../models/server.dart';
import '../torrent_server_base.dart';

class QBittorrentServer implements TorrentServerBase {
  factory QBittorrentServer({
    String? url,
    String? label,
    String? username,
    String? password,
  }) {
    final network = Network(
      Server(
        url: url ?? '',
        label: label,
        username: username ?? '',
        password: password ?? '',
      ),
      http.Client(),
    );

    final instance = QBittorrentServer._internal(
      url: url,
      label: label,
      username: username,
      password: password,
      client: network.client,
      network: network,
    );

    unawaited(instance._init());
    return instance;
  }

  QBittorrentServer._internal({
    required this.network,
    this.url,
    this.label,
    this.username,
    this.password,
    this.client,
  }) {
    torrentStreamController = StreamController<List<Torrent>>.broadcast();
    connectionStatusStreamController =
        StreamController<ServerState>.broadcast();
  }

  @visibleForTesting
  factory QBittorrentServer.test({
    required http.Client client,
    String? url,
    String? label,
    String? username,
    String? password,
  }) {
    final network = Network(
      Server(
        url: url ?? '',
        label: label,
        username: username ?? '',
        password: password ?? '',
      ),
      client,
    );

    return QBittorrentServer._internal(
      url: url,
      label: label,
      username: username,
      password: password,
      client: network.client,
      network: network,
    );
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

  @override
  late final StreamController<List<Torrent>> torrentStreamController;

  @override
  late final StreamController<ServerState> connectionStatusStreamController;

  @override
  final http.Client? client;

  final Network network;

  Future<void> _init() async {
    try {
      await network.authenticate();
    } catch (e) {
      final canConnect = await Network.isValid(network.server);
      connectionStatusStreamController.add(
        canConnect ? ServerState.error : ServerState.disconnected,
      );
    }

    unawaited(_periodicTorrentFetch());
    unawaited(_periodicConnectionCheck());
  }

  Future<void> torrentFetch() async {
    final torrents = await network.fetchTorrents();
    torrentStreamController.add(torrents);
  }

  Future<void> connectionCheck() async {
    try {
      await network.applicationVersion(timeout: const Duration(seconds: 2));
      connectionStatusStreamController.add(ServerState.connected);
    } on ConnectionException {
      connectionStatusStreamController.add(ServerState.disconnected);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      connectionStatusStreamController.add(ServerState.error);
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

  @override
  void dispose() {
    torrentStreamController.close();
    connectionStatusStreamController.close();
    client?.close();
  }
}
