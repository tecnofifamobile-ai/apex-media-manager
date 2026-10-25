import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../core/models/iptv_models.dart';

class XmltvParser {
  // Descarga y parseo en un Isolate secundario para no congelar la UI
  Future<Map<String, List<EpgProgram>>> fetchAndParse(String url) async {
    final response = await http
        .get(
          Uri.parse(url),
          headers: const {'User-Agent': 'APEX Media Manager'},
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw StateError('No se pudo descargar la guía EPG.');
    }
    return compute(_parseXmltv, response.body);
  }

  // Parseo pesudo ejecutado en background
  static Map<String, List<EpgProgram>> _parseXmltv(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);

    // Diccionario de channelId -> Lista de Programas
    final Map<String, List<EpgProgram>> epgMap = {};
    final Map<String, String> idToName = {};

    for (var channel in document.findAllElements('channel')) {
      final id = channel.getAttribute('id');
      if (id != null) {
        final displayName = channel
            .findElements('display-name')
            .firstOrNull
            ?.innerText;
        if (displayName != null) {
          idToName[id] = displayName;
        }
      }
    }

    for (var program in document.findAllElements('programme')) {
      final channelId = program.getAttribute('channel');
      if (channelId == null) continue;

      final title =
          program.findElements('title').firstOrNull?.innerText ?? 'Unknown';
      final desc = program.findElements('desc').firstOrNull?.innerText ?? '';
      final start = _parseXmltvDate(program.getAttribute('start') ?? '');
      final end = _parseXmltvDate(program.getAttribute('stop') ?? '');

      if (start != null && end != null) {
        final epgProg = EpgProgram(
          title: title,
          description: desc,
          start: start,
          end: end,
        );

        if (!epgMap.containsKey(channelId)) {
          epgMap[channelId] = [];
        }
        epgMap[channelId]!.add(epgProg);

        final displayName = idToName[channelId];
        if (displayName != null) {
          if (!epgMap.containsKey(displayName)) {
            epgMap[displayName] = [];
          }
          epgMap[displayName]!.add(epgProg);
        }
      }
    }

    return epgMap;
  }

  static DateTime? _parseXmltvDate(String dateStr) {
    try {
      if (dateStr.length < 14) return null;
      final year = int.parse(dateStr.substring(0, 4));
      final month = int.parse(dateStr.substring(4, 6));
      final day = int.parse(dateStr.substring(6, 8));
      final hour = int.parse(dateStr.substring(8, 10));
      final minute = int.parse(dateStr.substring(10, 12));
      final second = int.parse(dateStr.substring(12, 14));

      var dt = DateTime.utc(year, month, day, hour, minute, second);

      if (dateStr.length >= 19) {
        final tzSign = dateStr.substring(15, 16);
        final tzHours = int.parse(dateStr.substring(16, 18));
        final tzMinutes = int.parse(dateStr.substring(18, 20));

        final offset = Duration(hours: tzHours, minutes: tzMinutes);
        if (tzSign == '+') {
          dt = dt.subtract(offset);
        } else if (tzSign == '-') {
          dt = dt.add(offset);
        }
      }

      return dt.toLocal();
    } catch (e) {
      return null;
    }
  }
}
