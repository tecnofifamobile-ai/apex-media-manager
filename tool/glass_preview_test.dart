import 'dart:io';
import 'dart:convert';

import 'package:esptv_player/features/favorites/favorites_screen.dart';
import 'package:esptv_player/features/favorites/providers/league_favorites_provider.dart';

import '../test/league_favorites_test.dart' show sample;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esptv_player/core/models/iptv_models.dart';
import 'package:esptv_player/core/theme/app_theme.dart';
import 'package:esptv_player/core/widgets/main_layout.dart';
import 'package:esptv_player/features/auth/local_mode_provider.dart';
import 'package:esptv_player/features/channels/channels_screen.dart';
import 'package:esptv_player/features/favorites/providers/favorites_provider.dart';
import 'package:esptv_player/features/iptv_parser/providers/iptv_provider.dart';
import 'package:esptv_player/features/iptv_parser/providers/logo_provider.dart';
import 'package:esptv_player/features/iptv_parser/providers/category_provider.dart';

import '../test/lazy_channels_test.dart' show EmptyFavorites;

void main() {
  testWidgets('league bento desktop and mobile previews', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      'favorite_leagues_v1_preview': jsonEncode({
        'laliga': {},
        'champions': {},
        'nba': {},
      }),
    });
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('window_manager'),
      (call) async => call.method.startsWith('is') ? false : null,
    );
    final router = GoRouter(
      initialLocation: '/favorites',
      routes: [
        GoRoute(
          path: '/favorites',
          builder: (_, _) => const MainLayout(child: FavoritesScreen()),
        ),
      ],
    );
    addTearDown(router.dispose);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final key = GlobalKey();
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    tester.view.physicalSize = const Size(1440, 900);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          leagueProfileKeyProvider.overrideWithValue('preview'),
          channelsProvider.overrideWith((_) async => sample),
        ],
        child: RepaintBoundary(
          key: key,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.runAsync(() async {
      for (final asset in ['football.jpg', 'basketball.jpg']) {
        await precacheImage(
          ResizeImage(AssetImage('assets/images/leagues/$asset'), width: 1100),
          tester.element(find.byKey(key)),
        );
      }
      await precacheImage(
        const AssetImage('assets/images/leagues/laliga-logo.png'),
        tester.element(find.byKey(key)),
      );
    });
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(key),
      matchesGoldenFile(
        Uri.file('${Directory.current.path}/build/qa/leagues-desktop.png'),
      ),
    );
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(key),
      matchesGoldenFile(
        Uri.file('${Directory.current.path}/build/qa/leagues-mobile.png'),
      ),
    );
  });
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Outfit',
    )..addFont(rootBundle.load('assets/fonts/Outfit.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets('glass layout and compact quality dialog', (tester) async {
    // Flutter test entry point kept in tool/ for optional visual previews.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('window_manager'),
      (call) async => call.method.startsWith('is') ? false : null,
    );
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    LocalModeNotifier.initiallyEnabled = true;
    addTearDown(() => LocalModeNotifier.initiallyEnabled = false);
    final router = GoRouter(
      initialLocation: '/channels',
      routes: [
        GoRoute(
          path: '/channels',
          builder: (_, _) => const MainLayout(child: ChannelsScreen()),
        ),
      ],
    );
    addTearDown(router.dispose);
    final key = GlobalKey();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          channelsProvider.overrideWith(
            (ref) async => [
              for (final name in [
                'DAZN LALIGA 1',
                'DAZN LALIGA 2',
                'DAZN F1',
                'DAZN MOTOGP',
                'EUROSPORT 1',
                'EUROSPORT 2',
                'ESPN',
                'M+ VAMOS',
              ])
                for (final quality in ['FHD', 'HD', 'SD', 'HEVC'])
                  Channel(
                    name: '$name $quality',
                    url: 'http://localhost/stream',
                    group: 'EU | SPAIN',
                  ),
            ],
          ),
          logoDatabaseProvider.overrideWith((ref) async => {}),
          categoryDatabaseProvider.overrideWith((ref) async => {}),
          favoritesProvider.overrideWith(EmptyFavorites.new),
        ],
        child: RepaintBoundary(
          key: key,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(key),
      matchesGoldenFile(
        Uri.file('${Directory.current.path}/build/qa/glass-desktop.png'),
      ),
    );
    await tester.tap(find.byTooltip('Elegir calidad (4)').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(key),
      matchesGoldenFile(
        Uri.file('${Directory.current.path}/build/qa/glass-dialog.png'),
      ),
    );
  });
}
