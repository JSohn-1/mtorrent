class ConnectionException implements Exception {
  ConnectionException([this.message = 'Connection error occurred.']);
  final String message;

  @override
  String toString() => 'ConnectionException: $message';
}

class AuthenticationException implements Exception {
  AuthenticationException([this.message = 'Authentication failed.']);
  final String message;

  @override
  String toString() => 'AuthenticationException: $message';
}
