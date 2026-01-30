import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mtorrent/servers/models/server.dart';
import 'package:mtorrent/servers/qbittorent/base.dart';
import 'package:mtorrent/servers/qbittorent/network.dart';

import 'network.mocks.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<http.Client>(as: #MockHttpClient)])
void main() {
  final mockHttpClient = MockHttpClient();
  const endpoint = 'http://example.com';
  const cookie = 'SID=abcd1234';

  late QBittorrentServer serverInstance;
  group('streams', () {
    group('conncetionStatusStream', () {
      test('should emit connection status changes', () async {
        serverInstance = QBittorrentServer(
          url: endpoint,
          username: 'user',
          password: 'pass',
          httpClient: mockHttpClient,
          isTestMode: true,
        );

        serverInstance.network.cookie = cookie;

        final statuses = <bool>[];

        final statusesReady = Completer<void>();
        final subscription = serverInstance
            .connectionStatusStreamController
            .stream
            .listen((status) {
              statuses.add(status);
              if (statuses.length == 3) {
                statusesReady.complete();
              }
            });

        final okayResponse = http.Response('{"version":"4.3.3"}', 200);
        final failResponse = http.Response('Service Unavailable', 503);

        when(
          mockHttpClient.get(
            argThat(predicate<Uri>((uri) => uri.path == '/api/v2/app/version')),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => okayResponse);

        // First check - should be connected
        await serverInstance.connectionCheck();

        when(
          mockHttpClient.get(
            argThat(predicate<Uri>((uri) => uri.path == '/api/v2/app/version')),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => failResponse);

        // Second check - should be disconnected
        await serverInstance.connectionCheck();

        when(
          mockHttpClient.get(
            argThat(predicate<Uri>((uri) => uri.path == '/api/v2/app/version')),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => okayResponse);

        // Third check - should be connected again
        await serverInstance.connectionCheck();

        // Wait for all 3 statuses to be captured
        await statusesReady.future;

        expect(statuses, [true, false, true]);

        await subscription.cancel();
      });
    });
  });
}
