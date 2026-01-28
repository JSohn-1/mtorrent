import 'package:mtorrent/servers/models/server.dart';

import 'bittorent/base.dart';

enum ServerType {
  bittorrent,
  uTorrent,
}

class Servers {
  static Future<ServerType?> getServerType(Server server) async {
    if (await BittorrentServer.isValid(server)) {
      return ServerType.bittorrent;
    }

    return null;
  }
}