import 'dart:io';
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
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('Outfit')..addFont(rootBundle.load('assets/fonts/Outfit.ttf'))).load();
    await (FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  testWidgets('glass layout and compact quality dialog', (tester) async {
    // Flutter test entry point kept in tool/ for optional visual previews.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(const MethodChannel('window_manager'),
      (call) async => call.method.startsWith('is') ? false : null);
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    LocalModeNotifier.initiallyEnabled = true;
    addTearDown(() => LocalModeNotifier.initiallyEnabled = false);
    final router = GoRouter(initialLocation: '/channels', routes: [
      GoRoute(path: '/channels', builder: (_, _) => const MainLayout(child: ChannelsScreen())),
    ]);
    addTearDown(router.dispose);
    final key = GlobalKey();
    await tester.pumpWidget(ProviderScope(overrides: [
      channelsProvider.overrideWith((ref) async => [
        for (final name in ['DAZN LALIGA 1', 'DAZN LALIGA 2', 'DAZN F1', 'DAZN MOTOGP', 'EUROSPORT 1', 'EUROSPORT 2', 'ESPN', 'M+ VAMOS'])
          for (final quality in ['FHD', 'HD', 'SD', 'HEVC'])
            Channel(name: '$name $quality', url: 'http://localhost/stream', group: 'EU | SPAIN'),
      ]),
      logoDatabaseProvider.overrideWith((ref) async => {}),
      categoryDatabaseProvider.overrideWith((ref) async => {}),
      favoritesProvider.overrideWith(EmptyFavorites.new),
    ], child: RepaintBoundary(key: key, child: MaterialApp.router(debugShowCheckedModeBanner: false, theme: AppTheme.darkTheme, routerConfig: router))));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byKey(key), matchesGoldenFile(Uri.file('${Directory.current.path}/build/qa/glass-desktop.png')));
    await tester.tap(find.byTooltip('Elegir calidad (4)').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(find.byKey(key), matchesGoldenFile(Uri.file('${Directory.current.path}/build/qa/glass-dialog.png')));
  });
}
