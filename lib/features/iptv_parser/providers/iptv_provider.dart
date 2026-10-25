import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/iptv_models.dart';
import '../../../core/models/profile_model.dart';
import '../../profile/providers/profile_provider.dart';
import '../m3u_parser.dart';
import '../xc_client.dart';

final xtreamClientProvider = Provider<XtreamCodeClient?>((ref) {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null ||
      profile.type != ProfileType.xtreamCodes ||
      profile.xcUrl == null ||
      profile.xcUsername == null ||
      profile.xcPassword == null) {
    return null;
  }
  return XtreamCodeClient(
    baseUrl: profile.xcUrl!,
    username: profile.xcUsername!,
    password: profile.xcPassword!,
  );
});

final channelsProvider = FutureProvider<List<Channel>>((ref) async {
  final activeProfile = ref.watch(activeProfileProvider);

  if (activeProfile == null) return [];

  List<Channel> channels = [];

  if (activeProfile.type == ProfileType.xtreamCodes) {
    if (activeProfile.xcUrl != null &&
        activeProfile.xcUsername != null &&
        activeProfile.xcPassword != null) {
      try {
        final xcClient = XtreamCodeClient(
          baseUrl: activeProfile.xcUrl!,
          username: activeProfile.xcUsername!,
          password: activeProfile.xcPassword!,
        );
        channels = await xcClient.getChannels();
      } catch (e) {
        throw Exception('Error loading XC: $e');
      }
    }
  } else if (activeProfile.type == ProfileType.m3u) {
    if (activeProfile.m3uUrl != null && activeProfile.m3uUrl!.isNotEmpty) {
      try {
        final parser = M3uParser();
        channels = await parser.parseFromUrl(activeProfile.m3uUrl!);
      } catch (e) {
        throw Exception('Error loading M3U: $e');
      }
    }
  }

  // Override categories and names
  List<Channel> filteredChannels = [];
  for (int i = 0; i < channels.length; i++) {
    var c = channels[i];

    String upperName = c.name.toUpperCase();

    // Remove "M+ Cine" (not Español)
    if (upperName.contains('M+ CINE') && !upperName.contains('ESPA')) {
      continue;
    }

    // Normalize "Cine Español" qualities so they group together
    if (upperName.contains('CINE ESPA')) {
      String q = ' SD';
      if (upperName.contains('FHD') || upperName.contains('1080P')) {
        q = ' FHD';
      } else if (upperName.contains('HD') || upperName.contains('720P')) {
        q = ' HD';
      } else if (upperName.contains('4K')) {
        q = ' 4K';
      }

      c = c.copyWith(name: 'M+ CINE ESPAÑOL$q');
    }

    // Custom Smart Categorization ONLY for "MOVISTAR" group
    String group = c.group;
    String upperGroup = group.toUpperCase();

    if (upperGroup.contains('MOVISTAR') || upperGroup.contains('MOVIESTAR')) {
      if (upperName.contains('CINE') ||
          upperName.contains('ACCIÓN') ||
          upperName.contains('ACCION') ||
          upperName.contains('COMEDIA') ||
          upperName.contains('DRAMA') ||
          upperName.contains('CLÁSICOS') ||
          upperName.contains('CLASICOS') ||
          upperName.contains('INDIE') ||
          upperName.contains('RUNTIME') ||
          upperName.contains('HOLLYWOOD') ||
          upperName.contains('TCM') ||
          upperName.contains('AMC') ||
          upperName.contains('XTRM') ||
          upperName.contains('SOMOS')) {
        group = 'MOVISTAR CINE';
      } else if (upperName.contains('SERIES') ||
          upperName.contains('ESTRENOS') ||
          upperName.contains('NOVELA') ||
          upperName.contains('ELLAS') ||
          upperName.contains('FOX') ||
          upperName.contains('AXN') ||
          upperName.contains('CALLE 13') ||
          upperName.contains('SYFY') ||
          upperName.contains('COMEDY')) {
        group = 'MOVISTAR SERIES';
      } else if (upperName.contains('FEST') ||
          upperName.contains('MÚSICA') ||
          upperName.contains('MUSICA') ||
          upperName.contains('MTV') ||
          upperName.contains('VH1') ||
          upperName.contains('MEZZO')) {
        group = 'MOVISTAR MÚSICA';
      } else if (upperName.contains('DEPORTES') ||
          upperName.contains('LALIGA') ||
          upperName.contains('DAZN') ||
          upperName.contains('MOTO') ||
          upperName.contains('F1') ||
          upperName.contains('GOLF') ||
          upperName.contains('TENNIS') ||
          upperName.contains('SPORT') ||
          upperName.contains('EUROSPORT') ||
          upperName.contains('CAZA') ||
          upperName.contains('GOL') ||
          upperName.contains('REAL MADRID') ||
          upperName.contains('BARCA')) {
        group = 'MOVISTAR DEPORTES';
      } else if (upperName.contains('HISTORIA') ||
          upperName.contains('NATURA') ||
          upperName.contains('DOCUMENTAL') ||
          upperName.contains('VIAJES') ||
          upperName.contains('ODISEA') ||
          upperName.contains('NATIONAL') ||
          upperName.contains('DISCOVERY') ||
          upperName.contains('NAT GEO') ||
          upperName.contains('CRIMEN') ||
          upperName.contains('BLAZE')) {
        group = 'MOVISTAR DOCUMENTALES';
      } else if (upperName.contains('KIDS') ||
          upperName.contains('INFANTIL') ||
          upperName.contains('DISNEY') ||
          upperName.contains('NICKELODEON') ||
          upperName.contains('CARTOON') ||
          upperName.contains('BOING') ||
          upperName.contains('PANDA') ||
          upperName.contains('CLAN') ||
          upperName.contains('BABY')) {
        group = 'MOVISTAR INFANTIL';
      } else if (upperName.contains('NOTICIAS') ||
          upperName.contains('24H') ||
          upperName.contains('NEWS') ||
          upperName.contains('CNN') ||
          upperName.contains('BBC') ||
          upperName.contains('AL JAZEERA')) {
        group = 'MOVISTAR NOTICIAS';
      } else if (upperName.contains('LA 1') ||
          upperName.contains('LA 2') ||
          upperName.contains('ANTENA 3') ||
          upperName.contains('CUATRO') ||
          upperName.contains('TELECINCO') ||
          upperName.contains('LA SEXTA') ||
          upperName.contains('TRECE') ||
          upperName.contains('NEOX') ||
          upperName.contains('NOVA') ||
          upperName.contains('MEGA') ||
          upperName.contains('ENERGY') ||
          upperName.contains('FDF') ||
          upperName.contains('DIVINITY') ||
          upperName.contains('BEMAD') ||
          upperName.contains('TEN') ||
          upperName.contains('DMAX') ||
          upperName.contains('DKISS') ||
          upperName.contains('VEO7') ||
          upperName.contains('VAMOS') ||
          upperName.contains('ENFAMILIA') ||
          upperName.contains('EL CONFIDENCIAL') ||
          upperName.contains('40 Y 20')) {
        group = 'MOVISTAR GENERALISTAS';
      } else {
        group = 'MOVISTAR OTROS'; // Fallback for unmatched channels in Movistar
      }
    }

    c = c.copyWith(group: group);

    filteredChannels.add(c);
  }

  return filteredChannels;
});

final channelCategoriesProvider = Provider<List<String>>((ref) {
  final channelsAsync = ref.watch(channelsProvider);

  return channelsAsync.maybeWhen(
    data: (channels) {
      final Set<String> categories = {};
      for (var channel in channels) {
        if (channel.group.isNotEmpty) {
          categories.add(channel.group);
        }
      }
      final list = categories.toList()..sort();
      list.sort((a, b) {
        final isASpain = a.toUpperCase().startsWith('EU | SPAIN');
        final isBSpain = b.toUpperCase().startsWith('EU | SPAIN');
        if (isASpain && !isBSpain) return -1;
        if (!isASpain && isBSpain) return 1;

        final isAEu = a.toUpperCase().startsWith('EU |');
        final isBEu = b.toUpperCase().startsWith('EU |');
        if (isAEu && !isBEu) return -1;
        if (!isAEu && isBEu) return 1;

        return a.compareTo(b);
      });
      return list;
    },
    orElse: () => [],
  );
});

final moviesProvider = FutureProvider<List<VodItem>>((ref) async {
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile == null || activeProfile.type != ProfileType.xtreamCodes) {
    return [];
  }

  final xcClient = XtreamCodeClient(
    baseUrl: activeProfile.xcUrl!,
    username: activeProfile.xcUsername!,
    password: activeProfile.xcPassword!,
  );
  return await xcClient.getMovies();
});

final seriesProvider = FutureProvider<List<VodItem>>((ref) async {
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile == null || activeProfile.type != ProfileType.xtreamCodes) {
    return [];
  }

  final xcClient = XtreamCodeClient(
    baseUrl: activeProfile.xcUrl!,
    username: activeProfile.xcUsername!,
    password: activeProfile.xcPassword!,
  );
  return await xcClient.getSeries();
});
