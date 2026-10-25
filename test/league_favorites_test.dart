import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esptv_player/core/models/iptv_models.dart';
import 'package:esptv_player/core/theme/app_theme.dart';
import 'package:esptv_player/core/widgets/main_layout.dart';
import 'package:esptv_player/features/favorites/favorites_screen.dart';
import 'package:esptv_player/features/favorites/leagues.dart';
import 'package:esptv_player/features/favorites/providers/league_favorites_provider.dart';
import 'package:esptv_player/features/iptv_parser/providers/iptv_provider.dart';

final sample = [
  for (final number in [1, 2])
    for (final quality in ['HD', 'FHD'])
      Channel(
        name: 'DAZN LALIGA $number $quality',
        url: 'https://example.com/$number/$quality',
      ),
  Channel(
    name: 'M+ LIGA DE CAMPEONES HD',
    url: 'https://example.com/champions',
  ),
  Channel(name: 'NBA TV HD', url: 'https://example.com/nba'),
  Channel(name: 'DAZN 1 FHD', url: 'https://example.com/generic'),
  Channel(
    name: 'F1 Documentary',
    url: 'https://example.com/vod',
    isLive: false,
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('leagues keep channel choices and ordered qualities, excluding generic DAZN and VOD', () {
    final grouped = groupLeagueChannels(sample);
    expect(grouped['laliga']!.length, 2);
    expect(grouped['laliga']!.first.channels.first.name, 'DAZN LALIGA 1 FHD');
    expect(grouped['champions']!.length, 1);
    expect(grouped['nba']!.length, 1);
    expect(grouped.containsKey('f1'), isFalse);
    expect(grouped.values.expand((v) => v).expand((v) => v.channels).length, 6);
  });

  test(
    'concurrent league edits persist, survive restart and stay profile scoped',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final a = leagueFavoritesProvider('profile-a');
      await container.read(a.future);
      await Future.wait([
        container
            .read(a.notifier)
            .save(
              'nba',
              const LeagueChoice(url: 'nba-hd', channelName: 'NBA HD'),
            ),
        container.read(a.notifier).save('premier', const LeagueChoice()),
      ]);
      expect(
        container.read(a).requireValue.keys,
        containsAll(['nba', 'premier']),
      );
      container.invalidate(a);
      expect((await container.read(a.future))['nba']!.url, 'nba-hd');
      expect(
        (await container.read(leagueFavoritesProvider('profile-b').future))
            .containsKey('nba'),
        isFalse,
      );
      await container.read(a.notifier).save('laliga', null);
      container.invalidate(a);
      expect((await container.read(a.future)).containsKey('laliga'), isFalse);
    },
  );

  testWidgets(
    'league → channel → quality, saved replay, pointer and TV hold to change',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
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
          GoRoute(
            path: '/player',
            name: 'player',
            builder: (_, state) => Scaffold(
              body: Text('Playing ${(state.extra as Channel).name}'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            channelsProvider.overrideWith((_) async => sample),
            leagueProfileKeyProvider.overrideWithValue('widget-profile'),
          ],
          child: MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final tile = find.byKey(const ValueKey('league-laliga'));
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.text('Elige el canal'), findsOneWidget);
      await tester.tap(find.text('DAZN LALIGA 1'));
      await tester.pumpAndSettle();
      expect(find.text('Elige la calidad'), findsOneWidget);
      await tester.tap(find.text('DAZN LALIGA 1 HD'));
      await tester.pumpAndSettle();
      expect(find.text('Playing DAZN LALIGA 1 HD'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(find.text('Playing DAZN LALIGA 1 HD'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      await tester.longPress(tile);
      await tester.pumpAndSettle();
      await tester.tap(find.text('DAZN LALIGA 2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('DAZN LALIGA 2 FHD'));
      await tester.pumpAndSettle();
      expect(find.text('DAZN LALIGA 2 FHD'), findsOneWidget);
      expect(find.textContaining('Playing'), findsNothing);
      Focus.of(tester.element(find.text('El fútbol de aquí'))).requestFocus();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();
      expect(find.text('Elige el canal'), findsOneWidget);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      // Check the actual shell and cards on phone and TV-sized surfaces.
      for (final size in [const Size(390, 844), const Size(960, 540)]) {
        await tester.binding.setSurfaceSize(size);
        tester.view.physicalSize = size;
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );
}
