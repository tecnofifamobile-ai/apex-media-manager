import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/models/profile_model.dart';
import '../../../main.dart';
import 'profile_store.dart';
import '../../auth/local_mode_provider.dart';

final authChangesProvider = StreamProvider<AuthState>(
  (ref) => Supabase.instance.client.auth.onAuthStateChange,
);
final profileUserIdProvider = Provider<String?>((ref) {
  if (ref.watch(localModeProvider)) return 'local-device';
  ref.watch(authChangesProvider);
  return Supabase.instance.client.auth.currentUser?.id;
});
final profileStoreProvider = Provider<ProfileStore>(
  (ref) => SupabaseProfileStore(
    isar,
    Supabase.instance.client,
    localOnly: ref.watch(localModeProvider),
  ),
);

class ActiveProfileNotifier extends Notifier<Profile?> {
  @override
  Profile? build() {
    ref.watch(profileUserIdProvider);
    return null;
  }

  void setProfile(Profile profile) => state = profile;
}

final activeProfileProvider = NotifierProvider<ActiveProfileNotifier, Profile?>(
  ActiveProfileNotifier.new,
);

class ProfilesNotifier extends AsyncNotifier<List<Profile>> {
  int _generation = 0;

  @override
  Future<List<Profile>> build() async {
    final userId = ref.watch(profileUserIdProvider);
    final store = ref.watch(profileStoreProvider);
    final generation = ++_generation;
    if (userId == null) return [];
    final local = await store.readLocal(userId);
    if (local.isEmpty) {
      try {
        final remote = await store.fetchRemote(userId);
        if (!ref.mounted || generation != _generation) return local;
        await store.cache(userId, remote);
        return remote;
      } catch (_) {
        return local;
      }
    }
    // Start one background refresh after publishing the cached result.
    Timer.run(() {
      if (ref.mounted && generation == _generation) {
        unawaited(_syncOnce(store, userId, generation));
      }
    });
    return local;
  }

  Future<void> _syncOnce(
    ProfileStore store,
    String userId,
    int generation,
  ) async {
    try {
      final remote = await store.fetchRemote(userId);
      if (!ref.mounted || generation != _generation) return;
      await store.cache(userId, remote);
      if (ref.mounted && generation == _generation) state = AsyncData(remote);
    } catch (_) {
      debugPrint('Profile sync unavailable; using local profiles.');
    }
  }

  Future<void> addM3uProfile(
    String name,
    String url,
    String epgUrl,
    int colorCode,
  ) => _addProfile(
    Profile(
      id: const Uuid().v4(),
      name: name,
      type: ProfileType.m3u,
      m3uUrl: url,
      epgUrl: epgUrl,
      colorCode: colorCode,
    ),
  );

  Future<void> addXcProfile(
    String name,
    String username,
    String password,
    String url,
    int colorCode,
  ) => _addProfile(
    Profile(
      id: const Uuid().v4(),
      name: name,
      type: ProfileType.xtreamCodes,
      xcUsername: username,
      xcPassword: password,
      xcUrl: url,
      colorCode: colorCode,
    ),
  );

  Future<void> _addProfile(Profile profile) async {
    final userId = ref.read(profileUserIdProvider);
    if (userId == null) {
      throw StateError('Inicia sesión para guardar un perfil.');
    }
    final generation = ++_generation;
    final store = ref.read(profileStoreProvider);
    final saved = await store.insert(userId, profile);
    if (!ref.mounted ||
        generation != _generation ||
        ref.read(profileUserIdProvider) != userId) {
      return;
    }
    final profiles = [...?state.value, saved];
    await store.cache(userId, profiles);
    if (ref.mounted && generation == _generation) state = AsyncData(profiles);
  }
}

final profilesProvider = AsyncNotifierProvider<ProfilesNotifier, List<Profile>>(
  ProfilesNotifier.new,
);
