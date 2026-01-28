import 'models/server.dart';

import 'qbittorent/base.dart';
import 'torrent_server_base.dart';

enum ServerType {
  qbittorrent,
  uTorrent,
}

class Servers {
  static Future<ServerType?> getServerType(Server server) async {
    if (await QBittorrentServer.isValidServer(server)) {
      return ServerType.qbittorrent;
    }

    return null;
  }

  static TorrentServerBase? getServerInstance(Server server) {
    switch (server.type) {
      case 'qBittorrent':
        return QBittorrentServer(
          url: server.url,
          label: server.label,
          username: server.username,
          password: server.password,
        );
      default:
        return null;
    }
  }
}
