class Torrent {

  Torrent({required this.name, required this.size, required this.progress});

  factory Torrent.fromJson(Map<String, dynamic> json) => Torrent(
      name: json['name'] as String,
      size: json['size'] as int,
      progress: (json['progress'] as num).toDouble(),
    );
  final String name;
  final int size;
  final double progress;
}
