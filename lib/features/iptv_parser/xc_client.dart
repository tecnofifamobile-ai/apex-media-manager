import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/models/iptv_models.dart';

class XtreamCodeClient {
  final String baseUrl;
  final String username;
  final String password;

  XtreamCodeClient({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  String get _authQuery => 'username=$username&password=$password';

  Future<List<Channel>> getChannels() async {
    try {
      // 1. Obtener categorías
      final catResponse = await http.get(Uri.parse('$baseUrl/player_api.php?$_authQuery&action=get_live_categories')).timeout(const Duration(seconds: 15));
      Map<String, String> categoryMap = {};
      
      if (catResponse.statusCode == 200) {
        final List<dynamic> catData = json.decode(catResponse.body);
        for (var cat in catData) {
          categoryMap[cat['category_id'].toString()] = cat['category_name'].toString();
        }
      }

      // 2. Obtener streams
      final streamsResponse = await http.get(Uri.parse('$baseUrl/player_api.php?$_authQuery&action=get_live_streams')).timeout(const Duration(seconds: 15));
      if (streamsResponse.statusCode == 200) {
        final List<dynamic> streamsData = json.decode(streamsResponse.body);
        final List<Channel> channels = [];

        for (var stream in streamsData) {
          final streamId = stream['stream_id'];
          final categoryId = stream['category_id'].toString();
          
          String iconUrl = stream['stream_icon']?.toString().trim() ?? '';
          if (iconUrl.isNotEmpty) {
            if (iconUrl.startsWith('//')) {
              iconUrl = 'http:$iconUrl';
            } else if (iconUrl.startsWith('/')) {
              iconUrl = '$baseUrl$iconUrl';
            } else if (!iconUrl.startsWith('http')) {
              iconUrl = '$baseUrl/$iconUrl';
            }
            
            // Fix for panels that have broken HTTPS for images (e.g. returning 404 on HTTPS but 200 on HTTP)
            if (iconUrl.startsWith('https://')) {
              iconUrl = iconUrl.replaceFirst('https://', 'http://');
            }
          }
          
          channels.add(Channel(
            name: stream['name'] ?? 'Unknown',
            url: '$baseUrl/live/$username/$password/$streamId.ts', // URL estándar de Live Stream en XC
            group: categoryMap[categoryId] ?? 'General',
            logo: iconUrl,
            tvgId: stream['epg_channel_id']?.toString() ?? '',
          ));
        }

        // DEBUG LOG PARA VER POR QUE FALLAN LOS LOGOS
        try {
          final file = File('debug_xc.txt');
          await file.writeAsString(streamsData.map((s) => '${s['name']}: ${s['stream_icon']}').join('\n'));
        } catch(e) {}

        return channels;
      } else {
        throw Exception('Failed to load XC streams');
      }
    } catch (e) {
      throw Exception('Network error loading XC: $e');
    }
  }

  Future<List<VodItem>> getMovies() async {
    try {
      final streamsResponse = await http.get(Uri.parse('$baseUrl/player_api.php?$_authQuery&action=get_vod_streams'));
      if (streamsResponse.statusCode == 200) {
        final List<dynamic> streamsData = json.decode(streamsResponse.body);
        return streamsData.map((stream) {
          final streamId = stream['stream_id'].toString();
          return VodItem(
            id: streamId,
            name: stream['name'] ?? 'Unknown',
            streamIcon: stream['stream_icon']?.toString() ?? '',
            streamType: stream['stream_type']?.toString() ?? 'movie',
            containerExtension: stream['container_extension']?.toString() ?? 'mp4',
            categoryId: stream['category_id']?.toString() ?? '',
            rating: double.tryParse(stream['rating']?.toString() ?? '0') ?? 0.0,
          );
        }).toList();
      } else {
        throw Exception('Failed to load XC VOD streams');
      }
    } catch (e) {
      throw Exception('Network error loading VOD: $e');
    }
  }

  Future<List<VodItem>> getSeries() async {
    try {
      final streamsResponse = await http.get(Uri.parse('$baseUrl/player_api.php?$_authQuery&action=get_series'));
      if (streamsResponse.statusCode == 200) {
        final List<dynamic> streamsData = json.decode(streamsResponse.body);
        return streamsData.map((stream) {
          final streamId = stream['series_id'].toString();
          return VodItem(
            id: streamId,
            name: stream['name'] ?? 'Unknown',
            streamIcon: stream['cover']?.toString() ?? '',
            streamType: 'series',
            containerExtension: '',
            categoryId: stream['category_id']?.toString() ?? '',
            rating: double.tryParse(stream['rating']?.toString() ?? '0') ?? 0.0,
          );
        }).toList();
      } else {
        throw Exception('Failed to load XC Series streams');
      }
    } catch (e) {
      throw Exception('Network error loading Series: $e');
    }
  }
}
