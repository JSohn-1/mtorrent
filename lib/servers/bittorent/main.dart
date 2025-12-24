import 'dart:async';

import 'package:mtorrent/helpers/constants.dart';
import 'package:mtorrent/servers/models/torrent.dart';

import 'network.dart';
import '../models/server.dart';
import '../torrent_server_base.dart';

class BittorrentServer implements TorrentServerBase {
  static Future<bool> isValid(Server server) async {
    return await Network.isValid(server);
  }

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

  late final Network _network;

  BittorrentServer({this.url, this.label, this.username, this.password}) {
    torrentStreamController = StreamController<List<Torrent>>();

    _network = Network(Server(
      url: url ?? '',
      username: username ?? '',
      password: password ?? '',
    ));

    _init();
  }

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