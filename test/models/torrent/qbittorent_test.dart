import 'package:mtorrent/servers/servers.dart';

import 'package:mtorrent/servers/models/torrent.dart';

import 'package:flutter_test/flutter_test.dart';

// Test the json deserializer with qbittorent specific data

void main() {
  group('Torrent Model', () {
    test('should error on garbage data', () {
      final json = {'invalid_key': 'invalid_value'};

      expect(
        () => Torrent.fromJson(json, ServerType.qbittorrent),
        throwsA(isA<TypeError>()),
      );
    });
    test('fromJson creates Torrent object from JSON', () {
      final json = {
        'name': 'Example Torrent',
        'hash': 'abcd1234',
        'total_size': 1048576,
        'dlspeed': 1024,
        'upspeed': 512,
        'downloaded': 2048,
        'uploaded': 1024,
        'ratio': 0.5,
        'state': 'downloading',
        'size': 1048576,
        'progress': 0.16,
      };

      final torrent = Torrent.fromJson(json, ServerType.qbittorrent);

      expect(torrent.name, 'Example Torrent');
      expect(torrent.status, TorrentStatus.downloading);
      expect(torrent.sizeBytes, 1048576);
      expect(torrent.progress, 0.16);
    });
  });
}
