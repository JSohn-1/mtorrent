import 'models/server.dart';

import 'qbittorent/base.dart';

enum ServerType {
  bittorrent,
  uTorrent,
}

class Servers {
  static Future<ServerType?> getServerType(Server server) async {
    if (await QBittorrentServer.isValid(server)) {
      return ServerType.bittorrent;
    }

    return null;
  }
}
