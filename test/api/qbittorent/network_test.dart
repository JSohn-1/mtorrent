import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mtorrent/servers/qbittorent/network.dart';
import 'package:mtorrent/servers/models/server.dart';

import 'network.mocks.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<http.Client>(as: #MockHttpClient)])
void main() {
  group('network', () {
    final mockHttpClient = MockHttpClient();
    final endpoint = Uri.parse('http://example.com/api/v2/');
    const cookie = 'SID=abcd1234';

    late Network network;

    group('isValid', () {
      test('should return true when given valid server', () async {
        final response = http.Response('Fails.', 200);
        when(
          mockHttpClient.post(
            argThat(predicate<Uri>((uri) => uri.path == '/api/v2/auth/login')),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
            encoding: anyNamed('encoding'),
          ),
        ).thenAnswer((_) async => response);

        final isValid = await Network.isValid(
          Server(url: 'http://example.com', username: '', password: ''),
          mockHttpClient,
        );

        expect(isValid, true);
      });

      test('should return false when given invalid server', () async {
        final response = http.Response('Unauthorized', 401);
        when(
          mockHttpClient.post(
            argThat(predicate<Uri>((uri) => uri.path == '/api/v2/auth/login')),
            headers: anyNamed('headers'),
            body: anyNamed('body'),
            encoding: anyNamed('encoding'),
          ),
        ).thenAnswer((_) async => response);

        final isValid = await Network.isValid(
          Server(url: 'http://example.com', username: '', password: ''),
          mockHttpClient,
        );

        expect(isValid, false);
      });
    });

    group('applicationVersion', () {
      test('should return version string when request is successful', () async {
        final response = http.Response('{"version":"4.3.3"}', 200);
        when(
          mockHttpClient.get(
            argThat(predicate<Uri>((uri) => uri.path == '/api/v2/app/version')),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => response);

        network = Network(
          Server(url: 'http://example.com', username: '', password: ''),
          mockHttpClient,
        );
        network.cookie = cookie;

        final version = await network.applicationVersion();

        expect(version, '4.3.3');
      });

      test('should throw exception when request fails', () async {
        final response = http.Response('Unauthorized', 401);
        when(
          mockHttpClient.get(
            argThat(predicate<Uri>((uri) => uri.path == '/api/v2/app/version')),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => response);

        network = Network(
          Server(url: 'http://example.com', username: '', password: ''),
          mockHttpClient,
        );
        network.cookie = cookie;

        expect(
          () async => await network.applicationVersion(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
