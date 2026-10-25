import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../core/models/iptv_models.dart';

class M3uParser {
  Future<List<Channel>> parseFromUrl(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return await compute(parse, response.body);
      } else {
        throw Exception('Failed to load M3U: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error loading M3U: $e');
    }
  }

  static List<Channel> parse(String m3uContent) {
    final List<Channel> channels = [];
    final lines = m3uContent.split('\n');

    String currentName = '';
    String currentLogo = '';
    String currentGroup = '';
    String currentTvgId = '';

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      if (line.startsWith('#EXTINF:')) {
        if (currentName.isNotEmpty) {
          channels.add(
            Channel(
              name: currentName,
              url: 'dummy_separator',
              logo: currentLogo,
              group: currentGroup,
              tvgId: currentTvgId,
            ),
          );
        }
        currentName = _extractName(line);
        currentLogo = _extractAttribute(line, 'tvg-logo');
        if (currentLogo.isNotEmpty && currentLogo.startsWith('//')) {
          currentLogo = 'https:$currentLogo';
        }
        currentGroup = _extractAttribute(line, 'group-title');
        currentTvgId = _extractAttribute(line, 'tvg-id');
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        // Es una URL de un canal
        channels.add(
          Channel(
            name: currentName,
            url: line,
            logo: currentLogo,
            group: currentGroup,
            tvgId: currentTvgId,
          ),
        );
        // Reset variables
        currentName = '';
        currentLogo = '';
        currentGroup = '';
        currentTvgId = '';
      }
    }

    if (currentName.isNotEmpty) {
      channels.add(
        Channel(
          name: currentName,
          url: 'dummy_separator',
          logo: currentLogo,
          group: currentGroup,
          tvgId: currentTvgId,
        ),
      );
    }

    return channels;
  }

  static String _extractAttribute(String line, String attribute) {
    final regexWithQuotes = RegExp(
      '$attribute="([^"]*)"',
      caseSensitive: false,
    );
    final matchQuotes = regexWithQuotes.firstMatch(line);
    if (matchQuotes != null) {
      final val = matchQuotes.group(1)?.trim() ?? '';
      if (val.isNotEmpty) return val;
    }

    final regexWithoutQuotes = RegExp(
      '$attribute=([^ ]+)',
      caseSensitive: false,
    );
    final matchNoQuotes = regexWithoutQuotes.firstMatch(line);
    return matchNoQuotes?.group(1)?.trim() ?? '';
  }

  static String _extractName(String line) {
    final parts = line.split(',');
    if (parts.length > 1) {
      return parts.last.trim();
    }
    return 'Canal Desconocido';
  }
}
