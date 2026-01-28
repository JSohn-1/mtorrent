import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mtorrent/servers/bittorent/network.dart';
import 'package:mtorrent/servers/models/server.dart';

import 'network.mocks.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<http.Client>(as: #MockHttpClient)
])
void main() {
  group('network', () {
    final MockHttpClient mockHttpClient = MockHttpClient();
    final Uri endpoint = Uri.parse('http://example.com/api/v2/');
    final String cookie = 'SID=abcd1234';

    late final Network network;

    test('should return true when given valid server', () async {
      final response = http.Response('Fails.', 200);
      when(mockHttpClient.post(
        argThat(predicate<Uri>((uri) => uri.path == '/api/v2/auth/login')),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
        encoding: anyNamed('encoding'),
      )).thenAnswer((_) async => response);

      final isValid = await Network.isValid(
          Server(url: 'http://example.com', username: '', password: '')
          , mockHttpClient);

      expect(isValid, true);
    });

  });
}