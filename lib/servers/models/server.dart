class Server {
  final int? id;
  final String url;
  final String? label;
  final String username;
  final String password;
  final String? type;

  Server({
    this.id,
    required this.url,
    this.label,
    required this.username,
    required this.password,
    this.type,
  });
}