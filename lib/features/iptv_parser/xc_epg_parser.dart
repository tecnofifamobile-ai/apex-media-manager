import 'package:flutter/foundation.dart';

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/models/iptv_models.dart';

class XcEpgParser {
  Future<Map<String, List<EpgProgram>>> fetchAndParse(
    String baseUrl,
    String username,
    String password,
  ) async {
    final url =
        '$baseUrl/player_api.php?username=$username&password=$password&action=get_simple_data_table';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'ZenPlayer/1.0 (Windows NT 10.0; Win64; x64)'},
      );

      if (response.statusCode == 200) {
        try {
          final file = File('debug_xc_epg.txt');
          await file.writeAsString(
            response.body.substring(
              0,
              response.body.length > 2000 ? 2000 : response.body.length,
            ),
          );
        } catch (_) {
          /* Optional provider data may be absent. */
        }
        return await compute(_parseJsonEpg, response.body);
      } else {
        try {
          final file = File('debug_xc_epg_error.txt');
          await file.writeAsString(
            'Error ${response.statusCode}: ${response.body}',
          );
        } catch (_) {
          /* Optional provider data may be absent. */
        }
        throw Exception(
          'Failed to load simple data table: ${response.statusCode}',
        );
      }
    } catch (e) {
      try {
        final file = File('debug_xc_epg_error.txt');
        await file.writeAsString('Exception: $e');
      } catch (_) {
        /* Optional provider data may be absent. */
      }
      throw Exception('XC EPG Network Error: $e');
    }
  }

  static Map<String, List<EpgProgram>> _parseJsonEpg(String jsonContent) {
    final Map<String, List<EpgProgram>> epgMap = {};

    try {
      final decoded = json.decode(jsonContent);
      if (decoded is Map<String, dynamic>) {
        for (var streamId in decoded.keys) {
          final info = decoded[streamId];
          if (info == null || info is! Map) continue;

          final epgChannelId = info['epg_channel_id']?.toString() ?? streamId;
          final title = info['epg_title']?.toString() ?? '';
          if (title.isEmpty) continue;

          final start = _parseXcDate(info['epg_start']?.toString() ?? '');
          final end = _parseXcDate(info['epg_end']?.toString() ?? '');

          if (start != null && end != null) {
            final program = EpgProgram(
              title: title,
              description: info['epg_description']?.toString() ?? '',
              start: start,
              end: end,
            );

            if (!epgMap.containsKey(epgChannelId)) {
              epgMap[epgChannelId] = [];
            }
            epgMap[epgChannelId]!.add(program);
          }
        }
      } else if (decoded is List<dynamic>) {
        for (var info in decoded) {
          if (info == null || info is! Map) continue;

          final epgChannelId =
              info['epg_channel_id']?.toString() ??
              info['stream_id']?.toString() ??
              '';
          if (epgChannelId.isEmpty) continue;

          final title = info['epg_title']?.toString() ?? '';
          if (title.isEmpty) continue;

          final start = _parseXcDate(info['epg_start']?.toString() ?? '');
          final end = _parseXcDate(info['epg_end']?.toString() ?? '');

          if (start != null && end != null) {
            final program = EpgProgram(
              title: title,
              description: info['epg_description']?.toString() ?? '',
              start: start,
              end: end,
            );

            if (!epgMap.containsKey(epgChannelId)) {
              epgMap[epgChannelId] = [];
            }
            epgMap[epgChannelId]!.add(program);
          }
        }
      }
    } catch (e) {
      debugPrint('EPG provider unavailable.');
    }

    return epgMap;
  }

  static DateTime? _parseXcDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      // Generalmente en XC los tiempos en JSON vienen como "2024-05-10 12:00:00" o Unix Timestamp
      if (dateStr.contains('-') && dateStr.contains(':')) {
        return DateTime.parse(dateStr.replaceFirst(' ', 'T')).toLocal();
      }

      final unix = int.tryParse(dateStr.replaceAll(RegExp(r'[^0-9]'), ''));
      if (unix != null) {
        if (dateStr.length == 10) {
          return DateTime.fromMillisecondsSinceEpoch(unix * 1000).toLocal();
        }
        if (dateStr.length == 13) {
          return DateTime.fromMillisecondsSinceEpoch(unix).toLocal();
        }
      }
    } catch (_) {
      /* Optional provider data may be absent. */
    }
    return null;
  }
}
