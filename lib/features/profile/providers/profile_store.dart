import 'package:isar/isar.dart';

import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/isar_profile.dart';
import '../../../core/models/profile_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

abstract class ProfileStore {
  Future<List<Profile>> readLocal(String userId);
  Future<List<Profile>> fetchRemote(String userId);
  Future<void> cache(String userId, List<Profile> profiles);
  Future<Profile> insert(String userId, Profile profile);
}

class SupabaseProfileStore implements ProfileStore {
  SupabaseProfileStore(this.database, this.client, {this.localOnly = false});
  final bool localOnly;
  final Isar? database;
  final SupabaseClient client;

  Profile _fromJson(Map<String, dynamic> p) => Profile(
    id: p['id'] as String,
    name: p['name'] as String,
    type: p['type'] == 'm3u' ? ProfileType.m3u : ProfileType.xtreamCodes,
    m3uUrl: p['m3u_url'] as String?,
    epgUrl: p['epg_url'] as String?,
    xcUsername: p['xc_username'] as String?,
    xcPassword: p['xc_password'] as String?,
    xcUrl: p['xc_url'] as String?,
    colorCode: (p['color_code'] as num).toInt(),
  );

  @override
  Future<List<Profile>> readLocal(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final database = this.database;
    if (database == null) {
      final cached = prefs.getString('compatible_profiles_$userId');
      if (cached == null) return [];
      return (jsonDecode(cached) as List)
          .map((row) => _fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();
    }
    final rows = await database.isarProfiles
        .filter()
        .userIdEqualTo(userId)
        .findAll();
    return rows
        .map(
          (p) => Profile(
            id: p.syncId,
            name: p.name,
            type: p.type == 'm3u' ? ProfileType.m3u : ProfileType.xtreamCodes,
            m3uUrl: p.m3uUrl,
            epgUrl: prefs.getString('profile_epg_${userId}_${p.syncId}'),
            xcUsername: p.xcUsername,
            xcPassword: p.xcPassword,
            xcUrl: p.xcUrl,
            colorCode: p.colorCode,
          ),
        )
        .toList();
  }

  @override
  Future<List<Profile>> fetchRemote(String userId) async {
    if (localOnly) return readLocal(userId);
    final rows = await client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .timeout(const Duration(seconds: 15));
    final local = {for (final p in await readLocal(userId)) p.id: p};
    return rows.map((row) {
      final profile = _fromJson(row);
      return profile.copyWith(
        epgUrl: profile.epgUrl ?? local[profile.id]?.epgUrl,
      );
    }).toList();
  }

  @override
  Future<void> cache(String userId, List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final database = this.database;
    if (database == null) {
      await prefs.setString(
        'compatible_profiles_$userId',
        jsonEncode(
          profiles
              .map(
                (p) => {
                  'id': p.id,
                  'name': p.name,
                  'type': p.type == ProfileType.m3u ? 'm3u' : 'xtreamCodes',
                  'm3u_url': p.m3uUrl,
                  'epg_url': p.epgUrl,
                  'xc_username': p.xcUsername,
                  'xc_password': p.xcPassword,
                  'xc_url': p.xcUrl,
                  'color_code': p.colorCode,
                },
              )
              .toList(),
        ),
      );
      return;
    }
    for (final p in profiles) {
      if (p.epgUrl != null) {
        await prefs.setString('profile_epg_${userId}_${p.id}', p.epgUrl!);
      }
    }
    await database.writeTxn(() async {
      await database.isarProfiles.filter().userIdEqualTo(userId).deleteAll();
      for (final p in profiles) {
        await database.isarProfiles.put(
          IsarProfile()
            ..syncId = p.id
            ..userId = userId
            ..name = p.name
            ..type = p.type == ProfileType.m3u ? 'm3u' : 'xtreamCodes'
            ..m3uUrl = p.m3uUrl
            ..xcUsername = p.xcUsername
            ..xcPassword = p.xcPassword
            ..xcUrl = p.xcUrl
            ..colorCode = p.colorCode,
        );
      }
    });
  }

  @override
  Future<Profile> insert(String userId, Profile profile) async {
    if (localOnly) return profile;
    final row = await client
        .from('profiles')
        .insert({
          'user_id': userId,
          'name': profile.name,
          'type': profile.type == ProfileType.m3u ? 'm3u' : 'xtreamCodes',
          'm3u_url': profile.m3uUrl,
          'epg_url': profile.epgUrl,
          'xc_username': profile.xcUsername,
          'xc_password': profile.xcPassword,
          'xc_url': profile.xcUrl,
          'color_code': profile.colorCode,
        })
        .select()
        .single()
        .timeout(const Duration(seconds: 15));
    return _fromJson(row).copyWith(epgUrl: profile.epgUrl);
  }
}
