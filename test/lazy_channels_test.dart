import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esptv_player/core/models/iptv_models.dart';
import 'package:esptv_player/core/models/favorite_channel.dart';
import 'package:esptv_player/features/auth/local_mode_provider.dart';
import 'package:esptv_player/features/channels/channels_screen.dart';
import 'package:esptv_player/features/channels/widgets/iptv_image.dart';
import 'package:esptv_player/features/favorites/providers/favorites_provider.dart';
import 'package:esptv_player/features/iptv_parser/providers/iptv_provider.dart';
import 'package:esptv_player/features/iptv_parser/providers/logo_provider.dart';
import 'package:esptv_player/features/iptv_parser/providers/category_provider.dart';

class EmptyFavorites extends FavoritesNotifier {
  @override
  List<FavoriteChannel> build() => [];
}

void main() {
  testWidgets(
    '20,000 channels build only the visible cards and scroll lazily',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      LocalModeNotifier.initiallyEnabled = true;
      addTearDown(() => LocalModeNotifier.initiallyEnabled = false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localModeProvider.overrideWith(() => LocalModeNotifier()),
            channelsProvider.overrideWith(
              (ref) async => List.generate(
                20000,
                (i) => Channel(name: 'Channel $i', url: 'http://localhost/$i'),
              ),
            ),
            logoDatabaseProvider.overrideWith((ref) async => {}),
            categoryDatabaseProvider.overrideWith((ref) async => {}),
            favoritesProvider.overrideWith(EmptyFavorites.new),
          ],
          child: const MaterialApp(home: ChannelsScreen()),
        ),
      );
      // This test uses local mode to avoid updater/network initialization.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(IptvImage).evaluate().length, lessThan(100));
      expect(find.text('Channel 0'), findsOneWidget);
      Focus.of(tester.element(find.text('Channel 0'))).requestFocus();
      await tester.pump();
      for (var i = 0; i < 12; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
      }
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(scroll.position.pixels, greaterThan(200));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.byType(IptvImage).evaluate().length, lessThan(100));
      expect(tester.takeException(), isNull);
    },
  );
}
