import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:esptv_player/core/models/profile_model.dart';
import 'package:esptv_player/features/profile/providers/profile_store.dart';
import 'package:esptv_player/features/favorites/providers/favorites_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'profiles persist without a native database and remain separated by user',
    () async {
      final store = SupabaseProfileStore(
        null,
        SupabaseClient('https://example.invalid', 'public'),
        localOnly: true,
      );
      final p = Profile(
        id: 'one',
        name: 'TV',
        type: ProfileType.m3u,
        m3uUrl: 'http://localhost/list',
        epgUrl: 'http://localhost/guide',
        colorCode: 123,
      );
      await store.cache('first', [p]);
      expect((await store.readLocal('first')).single.epgUrl, p.epgUrl);
      expect(await store.readLocal('second'), isEmpty);
    },
  );
  test(
    'favourites, categories and quality preference survive a provider restart',
    () async {
      var container = ProviderContainer();
      final notifier = container.read(favoritesProvider.notifier);
      await notifier.toggleFavorite('demo');
      await notifier.setCategory('demo', 'Test');
      await notifier.updatePreferred(
        'demo',
        'http://localhost/demo',
        'Demo HD',
      );
      container.dispose();
      container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(favoritesProvider);
      await Future<void>.delayed(Duration.zero);
      final favorite = container.read(favoritesProvider).single;
      expect(favorite.category, 'Test');
      expect(favorite.preferredName, 'Demo HD');
    },
  );
}
