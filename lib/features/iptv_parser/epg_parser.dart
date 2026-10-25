import 'package:xml/xml.dart';

import '../../core/models/iptv_models.dart';

class EpgParser {
  static List<EpgProgram> parseXmltv(String xmlContent) {
    final List<EpgProgram> programs = [];
    final document = XmlDocument.parse(xmlContent);

    // Iterar sobre las etiquetas <programme>
    for (final element in document.findAllElements('programme')) {
      final channelId = element.getAttribute('channel') ?? '';
      final startStr = element.getAttribute('start') ?? '';
      final stopStr = element.getAttribute('stop') ?? '';

      final titleNode = element.findElements('title').firstOrNull;
      final descNode = element.findElements('desc').firstOrNull;

      if (channelId.isNotEmpty && startStr.isNotEmpty && stopStr.isNotEmpty) {
        programs.add(
          EpgProgram(
            title: titleNode?.innerText ?? 'Sin título',
            description: descNode?.innerText ?? 'Sin descripción',
            start: _parseXmltvDate(startStr),
            end: _parseXmltvDate(stopStr),
            channelId: channelId,
          ),
        );
      }
    }
    return programs;
  }

  static DateTime _parseXmltvDate(String dateStr) {
    // Formato típico XMLTV: 20260909210000 +0200
    if (dateStr.length >= 14) {
      final year = int.tryParse(dateStr.substring(0, 4)) ?? 2000;
      final month = int.tryParse(dateStr.substring(4, 6)) ?? 1;
      final day = int.tryParse(dateStr.substring(6, 8)) ?? 1;
      final hour = int.tryParse(dateStr.substring(8, 10)) ?? 0;
      final minute = int.tryParse(dateStr.substring(10, 12)) ?? 0;
      final second = int.tryParse(dateStr.substring(12, 14)) ?? 0;

      return DateTime.utc(year, month, day, hour, minute, second);
    }
    return DateTime.now();
  }
}
