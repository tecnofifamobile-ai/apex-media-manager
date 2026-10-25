import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _normalizeName(String n) {
  n = n.toLowerCase();

  // Remove accents using safe unicode escapes
  final Map<String, String> diacriticMap = {
    '\u00e1': 'a',
    '\u00e9': 'e',
    '\u00ed': 'i',
    '\u00f3': 'o',
    '\u00fa': 'u',
    '\u00fc': 'u',
    '\u00f1': 'n',
  };
  diacriticMap.forEach((from, to) {
    n = n.replaceAll(from, to);
  });

  // Strip anything before and including the last '|' (e.g. 'EU | SPAIN | ')
  n = n.replaceAll(RegExp(r'^.*\|\s*'), '');

  n = n.replaceAll('m+', '');
  n = n.replaceAll('movistar+', '');
  n = n.replaceAll('movistar', '');
  n = n.replaceAll('por', '');
  n = n.replaceAll('plus', '');
  n = n.replaceAll('liga de campeones', 'ligadecampeones');

  n = n.replaceAll('espana', '');
  n = n.replaceAll('espaa', '');

  n = n.replaceAll(
    RegExp(r'\b(fhd|hd|sd|4k|hevc|hdr|uhd|h265|vip|premium|1080p|720p|tv)\b'),
    '',
  );

  // Remove all non-alphanumeric characters
  n = n.replaceAll(RegExp(r'[^a-z0-9]'), '');

  return n.trim();
}

final Map<String, String> _logoCache = {};

String getLogoFallback(String originalName, Map<String, String> database) {
  if (database.isEmpty) return "";
  if (_logoCache.length > 4096) _logoCache.clear();
  if (_logoCache.containsKey(originalName)) {
    return _logoCache[originalName]!;
  }

  String normalized = _normalizeName(originalName);

  // Aliases for missing logos
  if (normalized.startsWith('daznlaliga')) normalized = 'daznlaliga';
  if (normalized.startsWith('ligadecampeones1') && normalized.length == 16) {
    normalized = 'ligadecampeones';
  }
  if (normalized == 'ligadecampeones18' || normalized == 'ligadecampeones19') {
    normalized = 'ligadecampeones';
  }
  if (normalized.startsWith('daznbaloncesto')) normalized = 'daznacb';
  if (normalized.contains('acb')) normalized = 'daznacb';
  if (normalized.startsWith('daznacb')) normalized = 'daznacb';
  if (normalized.contains('motogp')) normalized = 'daznmotogp';
  if (normalized.contains('formula1') || normalized.contains('f1')) {
    normalized = 'daznf1';
  }
  if (normalized.contains('daznevents') || normalized.contains('eventos')) {
    normalized = 'dazn';
  }
  if (normalized.contains('dazn1')) normalized = 'dazn1';
  if (normalized.contains('dazn2')) normalized = 'dazn2';
  if (normalized.contains('dazn3')) normalized = 'dazn3';
  if (normalized.contains('dazn4')) normalized = 'dazn4';
  if (normalized == 'mcine' ||
      normalized == 'cine' ||
      normalized.contains('cine')) {
    normalized = 'cine';
  }
  if (normalized == 'maccion' ||
      normalized == 'accion' ||
      normalized.contains('accion')) {
    normalized = 'accion';
  }
  if (normalized == 'mcomedia' ||
      normalized == 'comedia' ||
      normalized.contains('comedia')) {
    normalized = 'comedia';
  }
  if (normalized == 'mdrama' ||
      normalized == 'drama' ||
      normalized.contains('drama')) {
    normalized = 'drama';
  }
  if (normalized == 'mseries' ||
      normalized == 'series' ||
      normalized.contains('series')) {
    normalized = 'series';
  }
  if (normalized == 'mfest' ||
      normalized == 'fest' ||
      normalized.contains('fest')) {
    normalized = 'musica';
  }
  if (normalized == 'mindie' ||
      normalized == 'indie' ||
      normalized.contains('indie')) {
    normalized = 'indie';
  }
  if (normalized == 'mclasicos' ||
      normalized == 'clasicos' ||
      normalized.contains('clasicos')) {
    normalized = 'clasicos';
  }
  if (normalized.contains('estrenos')) {
    normalized = 'originales'; // Fallback for estrenos
  }
  if (normalized.contains('daznlaliga1') || normalized == 'daznlaliga') {
    normalized = 'daznlaliga';
  }

  if (database.containsKey(normalized)) {
    _logoCache[originalName] = database[normalized]!;
    return _logoCache[originalName]!;
  }

  _logoCache[originalName] = '';
  return '';
}

Future<Map<String, String>> _parseLogosInBackground(String jsonStr) async {
  final List<dynamic> paths = json.decode(jsonStr);
  final Map<String, String> logoMap = {};

  for (var path in paths) {
    final String pathStr = path.toString();

    final fileName = pathStr.split('/').last.replaceAll('.png', '');

    String n = fileName.toLowerCase();
    for (final suffix in ['-es', '-uk', '-us', '-de', '-fr']) {
      if (n.endsWith(suffix)) {
        n = n.substring(0, n.length - suffix.length);
        break;
      }
    }

    final normalized = _normalizeName(n);
    final rawUrl =
        'https://raw.githubusercontent.com/tv-logo/tv-logos/main/$pathStr';

    if (!logoMap.containsKey(normalized) || pathStr.contains('/spain/')) {
      logoMap[normalized] = rawUrl;
    }
  }

  // Custom overrides for DAZN MotoGP and DAZN ACB that the user requested
  logoMap['daznmotogp'] = 'https://daozombwhujwomhuaryq.supabase.co/storage/v1/object/public/releases/motogp-logo-v2.png';
  logoMap['daznacb'] = 'https://daozombwhujwomhuaryq.supabase.co/storage/v1/object/public/releases/acb-logo-v2.png';
  logoMap['daznbaloncesto'] = 'https://daozombwhujwomhuaryq.supabase.co/storage/v1/object/public/releases/acb-logo-v2.png';

  return logoMap;
}

final logoDatabaseProvider = FutureProvider<Map<String, String>>((ref) async {
  try {
    final jsonStr = await rootBundle.loadString('assets/tvlogos_paths.json');
    final db = await compute(_parseLogosInBackground, jsonStr);
    return db;
  } catch (e) {
    return {};
  }
});
