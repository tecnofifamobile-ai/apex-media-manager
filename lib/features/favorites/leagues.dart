import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/iptv_models.dart';
import '../channels/channel_groups.dart';
import '../iptv_parser/providers/iptv_provider.dart';

class League {
  const League(
    this.id,
    this.name,
    this.subtitle,
    this.words, {
    this.basketball = false,
  });
  final String id, name, subtitle;
  final List<String> words;
  final bool basketball;
  String get background => id == 'f1' || id == 'motogp'
      ? 'assets/images/bg_red.jpg'
      : 'assets/images/leagues/${basketball ? 'basketball' : 'football'}.jpg';
}

const leagues = [
  League('laliga', 'LALIGA', 'El fútbol de aquí', [
    'laliga',
    'la liga',
    'liga tv',
  ]),
  League('champions', 'CHAMPIONS LEAGUE', 'Las noches de Europa', [
    'champions',
    'campeones',
    'lcampeons',
  ]),
  League('premier', 'Premier League', 'Fútbol inglés', ['premier', 'epl']),
  League('bundesliga', 'Bundesliga', 'Fútbol alemán', ['bundesliga']),
  League('seriea', 'SERIE A', 'Fútbol italiano', [
    'serie a',
    'seriea',
    'calcio',
  ]),
  League('ligue1', 'LIGUE 1', 'Fútbol francés', ['ligue 1', 'ligue1']),
  League('f1', 'FORMULA 1', 'Cada curva cuenta', [
    'formula 1',
    'formula1',
    'f1',
  ]),
  League('motogp', 'MotoGP', 'Pasión por el motor', ['motogp', 'moto gp']),
  League('nba', 'NBA', 'El espectáculo del baloncesto', [
    'nba',
  ], basketball: true),
  League('acb', 'LIGA ENDESA', 'Baloncesto español', [
    'acb',
    'liga endesa',
  ], basketball: true),
];

String _normalize(String value) => value
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
    .trim();

/// Index once per playlist, keeping channel variants together inside each league.
Map<String, List<ChannelGroup>> groupLeagueChannels(List<Channel> channels) {
  final result = <String, Map<String, ChannelGroup>>{};
  final tokens = {
    for (final league in leagues)
      league.id: league.words.map(_normalize).toList(),
  };
  for (final channel in channels) {
    if (!channel.isLive) continue;
    final text = ' ${_normalize('${channel.name} ${channel.group}')} ';
    for (final league in leagues) {
      if (!tokens[league.id]!.any((word) => text.contains(' $word '))) continue;
      final id = channelIdentity(channel.name);
      final groups = result.putIfAbsent(league.id, () => {});
      final group = groups.putIfAbsent(
        id,
        () => ChannelGroup(id, league.name, []),
      );
      if (!group.channels.any((item) => item.url == channel.url)) {
        group.channels.add(channel);
      }
    }
  }
  return result.map((id, values) {
    final groups = values.values.toList()
      ..sort(
        (a, b) =>
            channelDisplayName(a.channels.first.name)
                .compareTo(channelDisplayName(b.channels.first.name)),
      );
    for (final group in groups) {
      group.channels.sort(
        (a, b) => qualityWeight(a.name).compareTo(qualityWeight(b.name)),
      );
    }
    return MapEntry(id, groups);
  });
}

final leagueChannelsProvider = Provider<Map<String, List<ChannelGroup>>>(
  (ref) => groupLeagueChannels(ref.watch(channelsProvider).value ?? []),
);

final leagueIdsByChannelProvider = Provider<Map<String, String>>(
  (ref) => {
    for (final entry in ref.watch(leagueChannelsProvider).entries)
      for (final group in entry.value) group.cleanName: entry.key,
  },
);
