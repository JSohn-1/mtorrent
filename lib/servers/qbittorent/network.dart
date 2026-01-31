import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';

import '../../helpers/constants.dart';
import '../../helpers/exceptions.dart';
import '../models/server.dart';
import '../models/torrent.dart';

class Network {
  Network(this.server, this.client);
  final Server server;
  final http.Client client;
  String? cookie;

  static Future<bool> isValid(Server server, {http.Client? client}) async {
    try {
      final baseUri = Uri.parse(server.url);
      final url = baseUri.replace(path: '/api/v2/auth/login');
      final httpClient = client ?? http.Client();
      final response = await httpClient
          .post(url)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Request timed out');
            },
          );
      return (response.statusCode == 200 && response.body == 'Fails.') ||
          (response.statusCode == 403 &&
              response.body ==
                  'Your IP address has been banned after too many failed authentication attempts.');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return false;
    }
  }

  void validateResponse(Response response) {
    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 403) {
      throw AuthenticationException(
        'Not signed in. Critical error, try reloading the app.',
      );
    }

    if (response.statusCode == 403) {
      throw AuthenticationException(response.body);
    }

    if (response.statusCode == 404) {
      throw AuthenticationException(
        'Critical API mismatch. Are you sure this is a qBittorrent server?',
      );
    }
    throw ConnectionException(
      'Request failed with status: ${response.statusCode}',
    );
  }

  Never handleException(Exception e) {
    if (e is SocketException) {
      throw ConnectionException('Network error: ${e.message}');
    } else if (e is http.ClientException) {
      throw ConnectionException('HTTP client error: ${e.message}');
    } else {
      throw e;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, String>? query,
    Duration? timeout,
  }) async {
    cookie ??= throw AuthenticationException('Not authenticated');

    final fullPath = '/api/v2/$path';

    final baseUri = Uri.parse(server.url);
    final url = baseUri.replace(path: fullPath, queryParameters: query);
    try {
      final response = await client
          .get(url, headers: {'Cookie': cookie!})
          .timeout(timeout ?? networkTimeout);
      // ignore: avoid_catches_without_on_clauses

      if (response.statusCode == 403) {
        await authenticate();
        final response2 = await client
            .get(url, headers: {'Cookie': cookie!})
            .timeout(timeout ?? networkTimeout);

        return response2;
      }

      return response;
    } catch (e) {
      return handleException(e as Exception);
    }
  }

  Future<Response> post(
    String path, {
    Map<String, String>? query,
    Map<String, String>? body,
    Duration? timeout,
  }) async {
    final fullPath = '/api/v2/$path';
    if (fullPath != '/api/v2/auth/login') {
      cookie ??= throw AuthenticationException('Not authenticated');
    }

    final baseUri = Uri.parse(server.url);
    final url = baseUri.replace(path: fullPath, queryParameters: query);
    try {
      final response = await client
          .post(
            url,
            body: body,
            headers: {if (cookie != null) 'Cookie': cookie!},
          )
          .timeout(timeout ?? networkTimeout);

      if (response.statusCode == 403 && fullPath != '/api/v2/auth/login') {
        await authenticate();

        final response2 = await client
            .post(url, body: body, headers: {'Cookie': cookie!})
            .timeout(timeout ?? networkTimeout);
        return response2;
      }
      return response;
    } catch (e) {
      return handleException(e as Exception);
    }
  }

  Future<void> authenticate() async {
    final body = {'username': server.username, 'password': server.password};

    final response = await post('auth/login', body: body);

    if (response.statusCode == 200 && response.body == 'Ok.') {
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        cookie = setCookie.split(';').first;
      }
    } else {
      throw Exception(
        'Authentication failed: ${response.statusCode}:${response.body}',
      );
    }
  }

  Future<String?> isValidCredentials() async {
    try {
      await authenticate();
      return null;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> applicationVersion({Duration? timeout}) async {
    final response = await get('app/version', timeout: timeout);

    validateResponse(response);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
        'Failed to fetch application version: ${response.statusCode}',
      );
    }
  }

  Future<List<Torrent>> fetchTorrents() async {
    final response = await get('torrents/info');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Torrent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch torrents');
    }
  }
}
