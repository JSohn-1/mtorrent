class Server {

  Server({
    required this.url, required this.username, required this.password, this.id,
    this.label,
    this.type,
  });
  final int? id;
  final String url;
  final String? label;
  final String username;
  final String password;
  final String? type;
}