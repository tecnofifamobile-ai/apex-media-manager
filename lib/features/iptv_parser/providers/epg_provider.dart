import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile_model.dart';
import '../../../core/models/iptv_models.dart';
import '../../profile/providers/profile_provider.dart';
import '../xmltv_parser.dart';

// Este proveedor lee el perfil activo, extrae su EPG URL y lanza el parser apropiado
final epgProvider = FutureProvider<Map<String, List<EpgProgram>>>((ref) async {
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile == null) return {};

  try {
    if (activeProfile.type == ProfileType.xtreamCodes) {
      if (activeProfile.xcUrl != null &&
          activeProfile.xcUsername != null &&
          activeProfile.xcPassword != null) {
        final base = activeProfile.xcUrl!.replaceFirst(RegExp(r'/+$'), '');
        final epgUrl = Uri.parse('$base/xmltv.php')
            .replace(
              queryParameters: {
                'username': activeProfile.xcUsername!,
                'password': activeProfile.xcPassword!,
              },
            )
            .toString();
        final parser = XmltvParser();
        return await parser.fetchAndParse(epgUrl);
      }
    } else {
      // Si es M3U, usar la epgUrl proporcionada
      final epgUrl = activeProfile.epgUrl;
      if (epgUrl != null && epgUrl.isNotEmpty) {
        final parser = XmltvParser();
        return await parser.fetchAndParse(epgUrl);
      }
    }
  } catch (e) {
    debugPrint('EPG unavailable.');
  }

  return {};
});
