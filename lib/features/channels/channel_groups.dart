import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/iptv_models.dart';
import '../iptv_parser/providers/iptv_provider.dart';
import 'providers/channels_filter_provider.dart';

final _qualityPattern = RegExp(
  r'\b(FHD|HD|SD|4K|HEVC|HDR|UHD|H265|VIP|PREMIUM|1080p|720p)\b',
  caseSensitive: false,
);
final _prefixPattern = RegExp(r'^.*?\|\s*');
final _backupPattern = RegExp(r'\[BK\]|\(BK\)|\bBK\b', caseSensitive: false);
final _nonAlphanumeric = RegExp(r'[^a-zA-Z0-9]');

String channelDisplayName(String name) => name
    .replaceAll(_prefixPattern, '')
    .replaceAll(
      RegExp(r'\blcampeons\b', caseSensitive: false),
      'LIGA DE CAMPEONES 1',
    )
    .replaceAll(_qualityPattern, '')
    .replaceAll(_backupPattern, '')
    .trim();
String channelIdentity(String name) =>
    channelDisplayName(name).replaceAll(_nonAlphanumeric, '').toLowerCase();

int qualityWeight(String name) {
  final upper = name.toUpperCase();
  if (upper.contains('4K') || upper.contains('UHD')) return 0;
  if (upper.contains('FHD') || upper.contains('1080')) return 1;
  if (upper.contains('HD') || upper.contains('720')) return 2;
  if (upper.contains('SD')) return 3;
  return 4;
}

class ChannelGroup {
  ChannelGroup(this.cleanName, this.category, this.channels);
  final String cleanName, category;
  final List<Channel> channels;
}

class ChannelSection {
  ChannelSection(this.name, this.groups);
  final String name;
  final List<ChannelGroup> groups;
}

List<ChannelSection> groupChannels(List<ChannelMetadata> metadata) {
  final sections = <String, Map<String, ChannelGroup>>{};
  for (final item in metadata) {
    final section = sections.putIfAbsent(item.subCategory, () => {});
    final id = channelIdentity(item.channel.name);
    section
        .putIfAbsent(id, () => ChannelGroup(id, item.subCategory, []))
        .channels
        .add(item.channel);
  }
  return (sections.keys.toList()..sort()).map((name) {
    final groups = sections[name]!.values.toList();
    for (final group in groups) {
      group.channels.sort((a, b) {
        final order = qualityWeight(a.name).compareTo(qualityWeight(b.name));
        return order == 0 ? a.name.compareTo(b.name) : order;
      });
    }
    return ChannelSection(name, groups);
  }).toList();
}

final channelSectionsProvider = Provider<List<ChannelSection>>(
  (ref) => groupChannels(ref.watch(filteredMetadataProvider)),
);

/// One index per playlist, shared by favourites instead of rescanning on hover.
final channelsByIdentityProvider = Provider<Map<String, List<Channel>>>((ref) {
  final index = <String, List<Channel>>{};
  for (final channel in ref.watch(channelsProvider).value ?? <Channel>[]) {
    index.putIfAbsent(channelIdentity(channel.name), () => []).add(channel);
  }
  return index;
});
