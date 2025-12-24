import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'dart:convert';

import '../models/server.dart';
import '../models/torrent.dart';

class Network {
  final Server server;
  String? cookie;

  Network(this.server);

  static Future<bool> isValid(Server server) async {
    try {
      final baseUri = Uri.parse(server.url);
      final url = baseUri.replace(path: '/api/v2/auth/login');
      final response = await http.post(url)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw Exception('Request timed out');
      });
      return (response.statusCode == 200 && response.body == 'Fails.') || (response.statusCode == 403 && response.body == 'Your IP address has been banned after too many failed authentication attempts.');
    } catch (e) {
      return false;
    }
  }

  Future<Response> get(String path, {Map<String, String>? query}) async {
    final baseUri = Uri.parse(server.url);
    final url = baseUri.replace(path: path, queryParameters: query);
    final response = await http.get(url, headers: {
      if (cookie != null) 'Cookie': cookie!,
    });
    return response;
  }

  Future<Response> post(String path, {Map<String, String>? query, Map<String, String>? body}) async {
    final baseUri = Uri.parse(server.url);
    final url = baseUri.replace(path: path, queryParameters: query);
    final response = await http.post(url, body: body, headers: {
      if (cookie != null) 'Cookie': cookie!,
    });
    return response;
  }

  Future<void> authenticate() async {
    final query = {
      'username': server.username,
      'password': server.password,
    };

    final response = await post('/api/v2/auth/login', query: query);

    if (response.statusCode == 200 && response.body == 'Ok.') {
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        cookie = setCookie.split(';').first;
      }
    } else {
      throw Exception('Authentication failed');
    }
  }

  Future<List<Torrent>> fetchTorrents() async {
    final response = await get('/api/v2/torrents/info');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Torrent.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch torrents');
    }
  }
}