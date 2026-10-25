import 'package:flutter_test/flutter_test.dart';
import 'package:esptv_player/core/models/iptv_models.dart';
import 'package:esptv_player/features/channels/channel_groups.dart';
import 'package:esptv_player/features/channels/providers/channels_filter_provider.dart';

void main() {
  test('20,000 variants consolidate into groups ordered by quality', () {
    final input = List.generate(
      20000,
      (i) => ChannelMetadata(
        channel: Channel(
          name: 'Channel ${i ~/ 4} ${['SD', 'HD', 'FHD', '4K'][i % 4]}',
          url: 'http://localhost/$i',
        ),
        country: 'España',
        category: 'General',
        subCategory: 'General',
        platform: 'Otros',
      ),
    );
    final watch = Stopwatch()..start();
    final sections = groupChannels(input);
    watch.stop();
    expect(sections.single.groups.length, 5000);
    expect(sections.single.groups.first.channels.first.name, 'Channel 0 4K');
    // Printed timing is diagnostic, not a machine-dependent pass threshold.
    // ignore: avoid_print
    print('Grouped 20,000 channel variants in ${watch.elapsedMilliseconds} ms');
  });
  test('favourites and live TV share channel identity', () {
    expect(
      channelIdentity('ES | M+ TEST FHD [BK]'),
      channelIdentity('M+ TEST HD'),
    );
    expect(
      channelIdentity('Sports 1 HD'),
      isNot(channelIdentity('Sports 2 HD')),
    );
  });
}
