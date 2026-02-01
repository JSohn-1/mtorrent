import '../servers.dart';
import 'data.dart';

enum TorrentStatus { downloading, seeding, paused, completed, error, unknown }

enum DataStorageUnit { bytes, kibibytes, mebibytes, gibibytes, tebibytes }

class Torrent {
  Torrent({
    required this.name,
    required this.id,
    required this.status,
    required this.sizeBytes,
    required this.downloadSpeedBytesPerSec,
    required this.uploadSpeedBytesPerSec,
    required this.downloadedBytes,
    required this.uploadedBytes,
    required this.ratio,
    required this.progress,
  });

  factory Torrent.fromJson(Map<String, dynamic> json, ServerType serverType) {
    switch (serverType) {
      case ServerType.qbittorrent:
        final name = json['name']! as String;
        final id = json['hash']! as String;

        final totalSizeNum = (json['total_size']!) as num;

        final dlBytesPerSec = json['dlspeed']! as num;
        final upBytesPerSec = json['upspeed']! as num;

        final downloadedNum = json['downloaded'] as num;
        final uploadedNum = json['uploaded'] as num;

        final ratioNum = json['ratio'] as num;
        final progressNum =
            (json['progress'] ?? 0) as num; // qBittorrent uses 0..1

        final stateStr = (json['state'] ?? '').toString();
        var status = TorrentStatus.unknown;
        switch (stateStr) {
          case 'downloading':
          case 'metaDL':
          case 'stalledDL':
          case 'queuedDL':
          case 'forcedDL':
            status = TorrentStatus.downloading;
            break;
          case 'uploading':
          case 'queuedUP':
          case 'stalledUP':
          case 'forcedUP':
          case 'checkingUP':
            status = TorrentStatus.seeding;
            break;
          case 'pausedDL':
          case 'pausedUP':
            status = TorrentStatus.paused;
            break;
          case 'error':
          case 'missingFiles':
            status = TorrentStatus.error;
            break;
          case 'unknown':
            status = TorrentStatus.unknown;
            break;
          default:
            if (progressNum >= 1.0) {
              status = TorrentStatus.completed;
            } else {
              status = TorrentStatus.unknown;
            }
        }

        return Torrent(
          name: name,
          id: id,
          status: status,
          sizeBytes: totalSizeNum.toInt(),
          downloadSpeedBytesPerSec: dlBytesPerSec.toInt(),
          uploadSpeedBytesPerSec: upBytesPerSec.toInt(),
          downloadedBytes: downloadedNum.toInt(),
          uploadedBytes: uploadedNum.toInt(),
          ratio: ratioNum.toDouble(),
          progress: progressNum.toDouble(),
        );

      default:
        throw UnimplementedError(
          'Torrent parsing not implemented for $serverType',
        );
    }
  }

  // Canonical (model) units: bytes and bytes/sec
  final String name;
  final String id;
  final TorrentStatus status;
  final int sizeBytes; // selected/downloaded size in bytes
  final int downloadSpeedBytesPerSec;
  final int uploadSpeedBytesPerSec;
  final int downloadedBytes;
  final int uploadedBytes;
  final double ratio;
  final double progress; // 0.0 .. 1.0

  Data _formatBytes(int bytes) {
    if (bytes >= 1 << 40) {
      return Data(value: (bytes / (1 << 40)).toStringAsFixed(2), unit: 'TiB');
    } else if (bytes >= 1 << 30) {
      return Data(value: (bytes / (1 << 30)).toStringAsFixed(2), unit: 'GiB');
    } else if (bytes >= 1 << 20) {
      return Data(value: (bytes / (1 << 20)).toStringAsFixed(2), unit: 'MiB');
    } else if (bytes >= 1 << 10) {
      return Data(value: (bytes / (1 << 10)).toStringAsFixed(2), unit: 'KiB');
    } else {
      return Data(value: '$bytes', unit: 'B');
    }
  }

  Data get sizeFormatted => _formatBytes(sizeBytes);

  Data get uploadedFormatted => _formatBytes(uploadedBytes);

  Data get downloadSpeedFormatted {
    final data = _formatBytes(downloadSpeedBytesPerSec);

    return Data(value: data.value, unit: '${data.unit}/s');
  }

  Data get uploadSpeedFormatted {
    final data = _formatBytes(uploadSpeedBytesPerSec);

    return Data(value: data.value, unit: '${data.unit}/s');
  }
}
