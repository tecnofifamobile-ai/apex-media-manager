import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:esptv_player/core/models/iptv_models.dart';
import 'package:esptv_player/features/iptv_parser/xc_client.dart';

void main() {
  test('movie URLs preserve special credentials and content type', () {
    final client = XtreamCodeClient(
      baseUrl: 'https://example.com/',
      username: 'a&b',
      password: 'p/?#',
    );
    final movie = client.movieChannel(
      VodItem(id: '42', name: 'Movie', containerExtension: 'mkv'),
    );
    expect(movie.url, 'https://example.com/movie/a%26b/p%2F%3F%23/42.mkv');
    expect(movie.isLive, isFalse);
  });
  test('series metadata produces season and episode playback URLs', () async {
    final mock = MockClient((request) async {
      expect(request.url.queryParameters['username'], 'a&b');
      expect(request.url.queryParameters['password'], 'p/?#');
      expect(request.url.queryParameters['series_id'], '12');
      return http.Response(
        jsonEncode({
          'episodes': {
            '2': [
              {
                'id': 32,
                'title': 'Second season',
                'container_extension': 'mkv',
              },
            ],
            '1': [
              {'id': 31, 'title': 'Pilot', 'container_extension': 'mp4'},
            ],
          },
        }),
        200,
      );
    });
    final client = XtreamCodeClient(
      baseUrl: 'https://example.com',
      username: 'a&b',
      password: 'p/?#',
      client: mock,
    );
    final seasons = await client.getEpisodes('12');
    expect(seasons.keys, ['1', '2']);
    expect(
      seasons['1']!.first.url,
      endsWith('/series/a%26b/p%2F%3F%23/31.mp4'),
    );
    expect(seasons['1']!.first.isLive, isFalse);
  });
  test('provider errors fail without exposing authenticated URLs', () async {
    final client = XtreamCodeClient(
      baseUrl: 'https://example.com',
      username: 'private',
      password: 'secret',
      client: MockClient((_) async => http.Response('unavailable', 503)),
    );
    await expectLater(client.getMovies(), throwsA(isA<StateError>()));
  });
}
