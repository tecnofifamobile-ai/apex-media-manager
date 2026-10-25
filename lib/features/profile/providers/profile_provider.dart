import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/profile_model.dart';
import '../../../core/models/isar_profile.dart';
import '../../../main.dart'; // Para acceder a la instancia `isar` global

class ActiveProfileNotifier extends Notifier<Profile?> {
  @override
  Profile? build() => null;

  void setProfile(Profile profile) {
    state = profile;
  }
}

final activeProfileProvider = NotifierProvider<ActiveProfileNotifier, Profile?>(() {
  return ActiveProfileNotifier();
});

class ProfilesNotifier extends AsyncNotifier<List<Profile>> {
  @override
  Future<List<Profile>> build() async {
    return _fetchProfiles();
  }

  Future<List<Profile>> _fetchProfiles() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    // 1. Cargar desde la base de datos local (Isar)
    final localProfiles = await isar.isarProfiles.filter().userIdEqualTo(userId).findAll();
    List<Profile> mappedProfiles = localProfiles.map((p) => Profile(
      id: p.syncId,
      name: p.name,
      type: p.type == 'm3u' ? ProfileType.m3u : ProfileType.xtreamCodes,
      m3uUrl: p.m3uUrl,
      xcUsername: p.xcUsername,
      xcPassword: p.xcPassword,
      xcUrl: p.xcUrl,
      colorCode: p.colorCode,
    )).toList();

    // 2. Opcional: Sincronizar con Supabase en segundo plano
    _syncWithSupabase(userId);

    return mappedProfiles;
  }

  Future<void> _syncWithSupabase(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('user_id', userId);
      
      final remoteProfiles = response as List<dynamic>;
      
      await isar.writeTxn(() async {
        for (var data in remoteProfiles) {
          final isarProfile = IsarProfile()
            ..syncId = data['id']
            ..userId = userId
            ..name = data['name']
            ..type = data['type']
            ..m3uUrl = data['m3u_url']
            ..xcUsername = data['xc_username']
            ..xcPassword = data['xc_password']
            ..xcUrl = data['xc_url']
            ..colorCode = data['color_code'];
            
          await isar.isarProfiles.putByIndex('syncId', isarProfile);
        }
      });
      
      // Actualizar estado si hubo cambios
      state = AsyncValue.data(await _fetchProfiles());
    } catch (e) {
      // Si falla, seguimos con los datos locales
      print('Supabase sync error: $e');
    }
  }

  Future<void> addM3uProfile(String name, String url, String epgUrl, int colorCode) async {
    await _addProfile(Profile(
      id: const Uuid().v4(),
      name: name,
      type: ProfileType.m3u,
      m3uUrl: url,
      epgUrl: epgUrl,
      colorCode: colorCode,
    ));
  }

  Future<void> addXcProfile(String name, String username, String password, String url, int colorCode) async {
    await _addProfile(Profile(
      id: const Uuid().v4(),
      name: name,
      type: ProfileType.xtreamCodes,
      xcUsername: username,
      xcPassword: password,
      xcUrl: url,
      colorCode: colorCode,
    ));
  }

  Future<void> _addProfile(Profile profile) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    // 1. Guardar en Supabase (siempre como fuente de la verdad para el ID)
    try {
      final insertData = {
        'user_id': userId,
        'name': profile.name,
        'type': profile.type == ProfileType.m3u ? 'm3u' : 'xtreamCodes',
        'm3u_url': profile.m3uUrl,
        'xc_username': profile.xcUsername,
        'xc_password': profile.xcPassword,
        'xc_url': profile.xcUrl,
        'color_code': profile.colorCode,
      };

      final response = await Supabase.instance.client.from('profiles').insert(insertData).select().single();
      final remoteId = response['id'] as String;

      // 2. Guardar en Isar
      final isarProfile = IsarProfile()
        ..syncId = remoteId
        ..userId = userId
        ..name = profile.name
        ..type = profile.type == ProfileType.m3u ? 'm3u' : 'xtreamCodes'
        ..m3uUrl = profile.m3uUrl
        ..xcUsername = profile.xcUsername
        ..xcPassword = profile.xcPassword
        ..xcUrl = profile.xcUrl
        ..colorCode = profile.colorCode;

      await isar.writeTxn(() async {
        await isar.isarProfiles.putByIndex('syncId', isarProfile);
      });

      // 3. Recargar estado
      state = AsyncValue.data(await _fetchProfiles());
    } catch (e) {
      throw Exception('Failed to save profile: $e');
    }
  }
}

final profilesProvider = AsyncNotifierProvider<ProfilesNotifier, List<Profile>>(() {
  return ProfilesNotifier();
});
