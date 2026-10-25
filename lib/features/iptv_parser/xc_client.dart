import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/models/iptv_models.dart';

dynamic _decodeJson(String text) => jsonDecode(text);

class XtreamCodeClient {
  XtreamCodeClient({
    required String baseUrl,
    required this.username,
    required this.password,
    this._client,
  }) : baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '');
  final String baseUrl, username, password;
  final http.Client? _client;

  Uri _api(String action, [Map<String, String> extra = const {}]) =>
      Uri.parse('$baseUrl/player_api.php').replace(
        queryParameters: {
          'username': username,
          'password': password,
          'action': action,
          ...extra,
        },
      );

  Future<dynamic> _request(
    String action, [
    Map<String, String> extra = const {},
  ]) async {
    final client = _client ?? http.Client();
    try {
      final response = await client
          .get(_api(action, extra))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw StateError('El proveedor respondió ${response.statusCode}.');
      }
      return await compute(_decodeJson, response.body);
    } finally {
      if (_client == null) client.close();
    }
  }

  String _streamUrl(String type, String id, String extension) =>
      '$baseUrl/$type/${Uri.encodeComponent(username)}/${Uri.encodeComponent(password)}/${Uri.encodeComponent(id)}.${Uri.encodeComponent(extension)}';
  String _imageUrl(dynamic value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return '';
    return Uri.parse('$baseUrl/').resolve(text).toString();
  }

  Future<List<Channel>> getChannels() async {
    final results = await Future.wait([
      _request('get_live_categories'),
      _request('get_live_streams'),
    ]);
    final categories = <String, String>{
      for (final item in results[0] as List)
        item['category_id'].toString(): item['category_name'].toString(),
    };
    return (results[1] as List)
        .map(
          (item) => Channel(
            name: item['name']?.toString() ?? 'Canal',
            url: _streamUrl('live', item['stream_id'].toString(), 'ts'),
            group: categories[item['category_id'].toString()] ?? 'General',
            logo: _imageUrl(item['stream_icon']),
            tvgId: item['epg_channel_id']?.toString() ?? '',
          ),
        )
        .toList();
  }

  Future<List<VodItem>> getMovies() async =>
      (await _request('get_vod_streams') as List)
          .map(
            (item) => VodItem(
              id: item['stream_id'].toString(),
              name: item['name']?.toString() ?? 'Película',
              streamIcon: _imageUrl(item['stream_icon']),
              containerExtension:
                  item['container_extension']?.toString() ?? 'mp4',
              categoryId: item['category_id']?.toString() ?? '',
              rating: double.tryParse(item['rating']?.toString() ?? '') ?? 0,
            ),
          )
          .toList();

  Channel movieChannel(VodItem movie) => Channel(
    name: movie.name,
    url: _streamUrl(
      'movie',
      movie.id,
      movie.containerExtension.isEmpty ? 'mp4' : movie.containerExtension,
    ),
    logo: movie.streamIcon,
    isLive: false,
  );

  Future<List<VodItem>> getSeries() async =>
      (await _request('get_series') as List)
          .map(
            (item) => VodItem(
              id: item['series_id'].toString(),
              name: item['name']?.toString() ?? 'Serie',
              streamIcon: _imageUrl(item['cover']),
              streamType: 'series',
              categoryId: item['category_id']?.toString() ?? '',
              rating: double.tryParse(item['rating']?.toString() ?? '') ?? 0,
            ),
          )
          .toList();

  Future<Map<String, List<Channel>>> getEpisodes(String seriesId) async {
    final response = await _request('get_series_info', {'series_id': seriesId});
    final episodes = response['episodes'];
    if (episodes is! Map) return {};
    final seasons = episodes.keys.map((key) => key.toString()).toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
    return {
      for (final season in seasons)
        season: (episodes[season] as List)
            .map(
              (episode) => Channel(
                name:
                    episode['title']?.toString() ??
                    'Episodio ${episode['episode_num']}',
                url: _streamUrl(
                  'series',
                  episode['id'].toString(),
                  episode['container_extension']?.toString() ?? 'mp4',
                ),
                logo: _imageUrl(episode['info']?['movie_image']),
                isLive: false,
              ),
            )
            .toList(),
    };
  }
}
