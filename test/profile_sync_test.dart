import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esptv_player/core/models/profile_model.dart';
import 'package:esptv_player/features/profile/providers/profile_provider.dart';
import 'package:esptv_player/features/profile/providers/profile_store.dart';

Profile profile(String id) => Profile(
  id: id,
  name: id,
  type: ProfileType.m3u,
  m3uUrl: 'https://example.com/list.m3u',
  colorCode: 0xFF123456,
);

class FakeStore implements ProfileStore {
  List<Profile> local = [profile('cached')];
  List<Profile> remote = [profile('remote')];
  int fetches = 0, reads = 0, writes = 0;
  bool offline = false;
  Completer<List<Profile>>? pending;
  @override
  Future<List<Profile>> readLocal(String userId) async {
    reads++;
    return local;
  }

  @override
  Future<List<Profile>> fetchRemote(String userId) async {
    fetches++;
    if (offline) throw StateError('offline');
    return pending?.future ?? remote;
  }

  @override
  Future<void> cache(String userId, List<Profile> profiles) async {
    writes++;
    local = profiles;
  }

  @override
  Future<Profile> insert(String userId, Profile value) async => value;
}

void main() {
  ProviderContainer container(FakeStore store) {
    final value = ProviderContainer(
      overrides: [
        profileUserIdProvider.overrideWithValue('test-user'),
        profileStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(value.dispose);
    return value;
  }

  test(
    'publishes cache then synchronizes once without recursive requests',
    () async {
      final store = FakeStore();
      final c = container(store);
      expect((await c.read(profilesProvider.future)).first.id, 'cached');
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(c.read(profilesProvider).value!.first.id, 'remote');
      expect(store.fetches, 1);
      expect(store.reads, 1);
      expect(store.writes, 1);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(store.fetches, 1);
    },
  );
  test('keeps cached profiles when remote is unavailable', () async {
    final store = FakeStore()..offline = true;
    final c = container(store);
    await c.read(profilesProvider.future);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(c.read(profilesProvider).value!.first.id, 'cached');
    expect(store.fetches, 1);
    expect(store.writes, 0);
  });
  test('first launch loads remote data with exactly one request', () async {
    final store = FakeStore()..local = [];
    final c = container(store);
    expect((await c.read(profilesProvider.future)).first.id, 'remote');
    expect(store.fetches, 1);
  });
  test('an older sync cannot overwrite a newly added profile', () async {
    final store = FakeStore()..pending = Completer<List<Profile>>();
    final c = container(store);
    await c.read(profilesProvider.future);
    await Future<void>.delayed(Duration.zero);
    await c
        .read(profilesProvider.notifier)
        .addM3uProfile('new', 'http://localhost/list', '', 0);
    store.pending!.complete([profile('stale')]);
    await Future<void>.delayed(Duration.zero);
    expect(c.read(profilesProvider).value!.any((p) => p.name == 'new'), isTrue);
    expect(
      c.read(profilesProvider).value!.any((p) => p.id == 'stale'),
      isFalse,
    );
  });
}
