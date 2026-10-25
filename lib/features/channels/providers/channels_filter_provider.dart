import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/iptv_models.dart';
import '../../iptv_parser/providers/iptv_provider.dart';
import '../../iptv_parser/providers/category_provider.dart';

class SearchFilterNotifier extends Notifier<String> {
  void setValue(String value) => state = value;
  @override
  String build() => '';
}

final searchFilterProvider = NotifierProvider<SearchFilterNotifier, String>(
  SearchFilterNotifier.new,
);

class CountryFilterNotifier extends Notifier<String?> {
  void setValue(String? value) => state = value;
  @override
  String? build() => null;
}

final countryFilterProvider = NotifierProvider<CountryFilterNotifier, String?>(
  CountryFilterNotifier.new,
);

class CategoryFilterNotifier extends Notifier<String?> {
  void setValue(String? value) => state = value;
  @override
  String? build() => null;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, String?>(
      CategoryFilterNotifier.new,
    );

class PlatformFilterNotifier extends Notifier<String?> {
  void setValue(String? value) => state = value;
  @override
  String? build() => null;
}

final platformFilterProvider =
    NotifierProvider<PlatformFilterNotifier, String?>(
      PlatformFilterNotifier.new,
    );

// 2. Parsed Metadata Class
class ChannelMetadata {
  final Channel channel;
  final String country;
  final String category;
  final String subCategory;
  final String platform;

  ChannelMetadata({
    required this.channel,
    required this.country,
    required this.category,
    required this.subCategory,
    required this.platform,
  });
}

// 3. Provider that maps Channels to Metadata
final channelMetadataListProvider = Provider<List<ChannelMetadata>>((ref) {
  final channelsAsync = ref.watch(channelsProvider);
  final categoryDb = ref.watch(categoryDatabaseProvider).value ?? {};

  return channelsAsync.maybeWhen(
    data: (channels) {
      return channels.map((c) {
        String group = c.group.toUpperCase();
        String name = c.name.toUpperCase();
        String normName = c.name.toLowerCase().replaceAll(
          RegExp(r'[^a-z0-9]'),
          '',
        );

        // Parse Country
        String country = 'Otros';
        if (group.startsWith('EU | ')) {
          country = group.split(' | ')[1].trim().split(' ').first;
        } else if (group.startsWith('AM | ')) {
          country = group.split(' | ')[1].trim().split(' ').first;
        } else if (group.startsWith('AF | ') || group.startsWith('AS | ')) {
          country = group.split(' | ')[1].trim().split(' ').first;
        } else if (group.contains('MOVISTAR') ||
            normName.startsWith('mplus') ||
            normName.startsWith('m2plus') ||
            normName.startsWith('mvamos')) {
          country = 'España'; // MOVISTAR belongs to Spain
        }

        if (country.isEmpty) {
          country = 'Bangladesh'; // Fallback if empty space parsed
        }

        // Convert to Title Case (e.g. AFGHANISTAN -> Afghanistan)
        if (country.length > 1) {
          country =
              country[0].toUpperCase() + country.substring(1).toLowerCase();
        }

        // Clean Country names
        if (country.toUpperCase() == 'LATINO') country = 'Latinoamérica';
        if (country.toUpperCase() == 'SPAIN') country = 'España';
        if (country.toUpperCase() == 'UK') country = 'Reino Unido';
        if (country.toUpperCase() == 'US' || country.toUpperCase() == 'USA') {
          country = 'Estados Unidos';
        }

        // Parse Category (Keyword Heuristic FIRST, then DB)
        String category = 'General';

        if (name.contains('CINE') ||
            name.contains('HOLLYWOOD') ||
            name.contains('XTRM') ||
            name.contains('TCM') ||
            name.contains('PARAMOUNT') ||
            name.contains('SOMOS') ||
            name.contains('DARK') ||
            name.contains('COMEDIA') ||
            name.contains('DRAMA') ||
            name.contains('ACCION') ||
            name.contains('ACCIÓN') ||
            name.contains('CLÁSICO') ||
            name.contains('CLASICO') ||
            name.contains('INDIE') ||
            name.contains('FEST') ||
            name.contains('ESTRENOS')) {
          category = 'Cine';
        } else if (name.contains('SERIES') ||
            name.contains('FOX') ||
            name.contains('AXN') ||
            name.contains('TNT') ||
            name.contains('SYFY') ||
            name.contains('AMC') ||
            name.contains('CALLE 13') ||
            name.contains('ENERGY') ||
            name.contains('FDF') ||
            name.contains('ORIGINALES')) {
          category = 'Series';
        } else if (name.contains('SPORT') ||
            name.contains('DEPORTE') ||
            name.contains('DAZN') ||
            name.contains('LALIGA') ||
            name.contains('LIGA') ||
            name.contains('CAMPEON') ||
            name.contains('F1') ||
            name.contains('GOLF') ||
            name.contains('TENNIS') ||
            name.contains('TENIS') ||
            name.contains('CAZA') ||
            name.contains('PESCA') ||
            name.contains('MOTOR') ||
            name.contains('VAMOS') ||
            name.contains('GOL PLAY') ||
            name.contains('EUROSPORT') ||
            name.contains('ESPN') ||
            name.contains('UFC')) {
          category = 'Deportes';
        } else if (name.contains('DOCU') ||
            name.contains('HISTORIA') ||
            name.contains('NATURA') ||
            name.contains('DISCOVERY') ||
            name.contains('NAT GEO') ||
            name.contains('ODISEA') ||
            name.contains('VIAJAR') ||
            name.contains('CRIME') ||
            name.contains('DMAX')) {
          category = 'Documentales';
        } else if (name.contains('KIDS') ||
            name.contains('INFANTIL') ||
            name.contains('DISNEY') ||
            name.contains('NICKELODEON') ||
            name.contains('NICK') ||
            name.contains('BOING') ||
            name.contains('CLAN') ||
            name.contains('CARTOON') ||
            name.contains('BABY') ||
            name.contains('PANDA')) {
          category = 'Infantil';
        } else if (name.contains('NEWS') ||
            name.contains('NOTICIAS') ||
            name.contains('24H') ||
            name.contains('CNN') ||
            name.contains('BBC') ||
            name.contains('AL JAZEERA') ||
            name.contains('RT') ||
            name.contains('CNBC') ||
            name.contains('BLOOMBERG') ||
            name.contains('EURONEWS') ||
            name.contains('NEGOCIOS')) {
          category = 'Noticias';
        } else if (name.contains('MUSIC') ||
            name.contains('MÚSICA') ||
            name.contains('MUSICA') ||
            name.contains('MTV') ||
            name.contains('VH1') ||
            name.contains('MEZZO') ||
            name.contains('TRACE')) {
          category = 'Música';
        } else if (name.contains('CANAL SUR') ||
            name.contains('TV3') ||
            name.contains('TVG') ||
            name.contains('GALICIA') ||
            name.contains('ETB') ||
            name.contains('TELEMADRID') ||
            name.contains('LA OTRA') ||
            name.contains('MELILLA') ||
            name.contains('A PUNT') ||
            name.contains('ARAGON') ||
            name.contains('IBERALIA')) {
          category = 'Autonómicos';
        } else if (categoryDb.containsKey(normName)) {
          // Fallback to JSON Database if no keyword matched
          category = categoryDb[normName]!;
        } else if (group.contains('CINE')) {
          category = 'Cine';
        } else if (group.contains('SERIES')) {
          category = 'Series';
        } else if (group.contains('SPORT') || group.contains('DEPORTE')) {
          category = 'Deportes';
        } else if (group.contains('MUSIC')) {
          category = 'Música';
        } else if (group.contains('KIDS') || group.contains('INFANTIL')) {
          category = 'Infantil';
        } else if (group.contains('DOCU')) {
          category = 'Documentales';
        } else if (group.contains('NEWS') || group.contains('NOTICIAS')) {
          category = 'Noticias';
        }

        // Parse Platform
        String platform = 'Otros';
        if (name.contains('DAZN')) {
          platform = 'DAZN';
        } else if (name.contains('M+') || group.contains('MOVISTAR')) {
          platform = 'Movistar+';
        } else if (name.contains('ESPN')) {
          platform = 'ESPN';
        } else if (name.contains('SKY')) {
          platform = 'Sky';
        } else if (name.contains('BEIN')) {
          platform = 'beIN';
        } else if (name.contains('FOX')) {
          platform = 'FOX';
        }

        String subCategory = 'General';
        if (category == 'Deportes') {
          if (name.contains('DAZN')) {
            subCategory = 'DAZN';
          } else if (name.contains('MOVISTAR LALIGA') ||
              name.contains('M+ LALIGA') ||
              name.contains('LA LIGA')) {
            subCategory = 'LaLiga';
          } else if (name.contains('LIGA DE CAMPEONES') ||
              name.contains('LCAMPEON')) {
            subCategory = 'Liga de Campeones';
          } else if (name.contains('EUROSPORT')) {
            subCategory = 'Eurosport';
          } else if (name.contains('GOL')) {
            subCategory = 'Gol / Deportes Abierto';
          } else if (name.contains('CAZA') ||
              name.contains('PESCA') ||
              name.contains('MOTOR') ||
              name.contains('F1')) {
            subCategory = 'Motor y Caza';
          } else {
            subCategory = 'Otros Deportes';
          }
        } else if (category == 'Cine' || category == 'Series') {
          if (name.contains('M+') || name.contains('MOVISTAR')) {
            subCategory = 'Movistar Cine y Series';
          } else if (name.contains('FOX') ||
              name.contains('AXN') ||
              name.contains('TNT') ||
              name.contains('SYFY') ||
              name.contains('CALLE 13')) {
            subCategory = 'Series Premium';
          } else if (name.contains('HOLLYWOOD') ||
              name.contains('TCM') ||
              name.contains('SOMOS') ||
              name.contains('PARAMOUNT')) {
            subCategory = 'Cine Premium';
          } else {
            subCategory = 'Cine y Series (Otros)';
          }
        } else if (category == 'Autonómicos' || category == 'Autonmicos') {
          subCategory = 'Canales Autonómicos';
        } else if (category == 'Infantil') {
          if (name.contains('DISNEY')) {
            subCategory = 'Disney';
          } else if (name.contains('NICKELODEON') || name.contains('NICK')) {
            subCategory = 'Nickelodeon';
          } else {
            subCategory = 'Infantil';
          }
        } else if (category == 'Documentales') {
          if (name.contains('DISCOVERY')) {
            subCategory = 'Discovery';
          } else if (name.contains('NAT GEO')) {
            subCategory = 'National Geographic';
          } else if (name.contains('HISTORIA')) {
            subCategory = 'Historia';
          } else {
            subCategory = 'Documentales';
          }
        } else if (category == 'Noticias') {
          if (name.contains('24H')) {
            subCategory = '24 Horas';
          } else {
            subCategory = 'Noticias';
          }
        } else {
          if (name.contains('LA 1') ||
              name.contains('LA 2') ||
              name.contains('ANTENA 3') ||
              name.contains('CUATRO') ||
              name.contains('TELECINCO') ||
              name.contains('LA SEXTA') ||
              name.contains('NEOX') ||
              name.contains('NOVA') ||
              name.contains('MEGA') ||
              name.contains('TRECE') ||
              name.contains('DMAX')) {
            subCategory = 'Nacionales (TDT)';
          } else {
            subCategory = 'General';
          }
        }

        return ChannelMetadata(
          channel: c,
          country: country,
          category: category,
          subCategory: subCategory,
          platform: platform,
        );
      }).toList();
    },
    orElse: () => [],
  );
});

// 4. Provider that returns available filter options
final availableFiltersProvider = Provider<Map<String, List<String>>>((ref) {
  final metadataList = ref.watch(channelMetadataListProvider);

  final countries = metadataList.map((m) => m.country).toSet().toList();
  final categories = metadataList.map((m) => m.category).toSet().toList()
    ..sort();
  final platforms = metadataList.map((m) => m.platform).toSet().toList()
    ..sort();

  // Core countries to show at the top
  final coreCountries = [
    'España',
    'Latinoamérica',
    'Estados Unidos',
    'Reino Unido',
  ];

  countries.sort((a, b) {
    int idxA = coreCountries.indexOf(a);
    int idxB = coreCountries.indexOf(b);

    if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
    if (idxA != -1) return -1;
    if (idxB != -1) return 1;

    if (a == 'Otros') return 1; // Otros at the very end
    if (b == 'Otros') return -1;

    return a.compareTo(b);
  });

  return {
    'countries': countries,
    'categories': categories,
    'platforms': platforms,
  };
});

// 5. Final Filtered Provider
final filteredMetadataProvider = Provider<List<ChannelMetadata>>((ref) {
  final metadataList = ref.watch(channelMetadataListProvider);
  final search = ref.watch(searchFilterProvider).toLowerCase();
  final country = ref.watch(countryFilterProvider);
  final category = ref.watch(categoryFilterProvider);
  final platform = ref.watch(platformFilterProvider);

  final filtered = metadataList.where((m) {
    if (search.isNotEmpty && !m.channel.name.toLowerCase().contains(search)) {
      return false;
    }
    if (country != null && m.country != country) return false;
    if (category != null && m.category != category) return false;
    if (platform != null && m.platform != platform) return false;

    // Ignore M3U separators
    if (m.channel.url == 'dummy_separator') return false;
    final nameLower = m.channel.name.toLowerCase();
    if (nameLower.contains('===') ||
        nameLower.contains('---') ||
        nameLower.contains('separador') ||
        nameLower.contains('separator')) {
      return false;
    }

    return true;
  }).toList();

  Map<String, List<ChannelMetadata>> grouped = {};
  for (final m in filtered) {
    grouped.putIfAbsent(m.category, () => []).add(m);
  }

  final sortedCategories = grouped.keys.toList()..sort();
  List<ChannelMetadata> result = [];
  for (final cat in sortedCategories) {
    result.addAll(grouped[cat]!);
  }
  return result;
});
