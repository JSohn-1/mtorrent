import 'dart:async';

import 'package:http/http.dart' as http;
import '../../helpers/constants.dart';
import '../models/torrent.dart';

import 'network.dart';
import '../models/server.dart';
import '../torrent_server_base.dart';

class QBittorrentServer implements TorrentServerBase {

  QBittorrentServer({this.url, this.label, this.username, this.password, http.Client? client}) : client = client ?? http.Client() {
    torrentStreamController = StreamController<List<Torrent>>();

    _network = Network(Server(
      url: url ?? '',
      username: username ?? '',
      password: password ?? '',
    ), client!);

    _init();
  }
  static Future<bool> isValid(Server server) async => await Network.isValid(server);

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
  final http.Client? client;

  late final Network _network;

  Future<void> _init() async {
    try {
      await _network.authenticate();

      Timer.periodic(refreshInterval, (_) async {
        final torrents = await _network.fetchTorrents();
        torrentStreamController.add(torrents);
      });
    } catch (e) {
      torrentStreamController.addError(e);
    }
  }
}