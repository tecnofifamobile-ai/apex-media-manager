import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../profile/providers/profile_provider.dart';

class LeagueChoice {
  const LeagueChoice({this.url, this.channelName});
  final String? url, channelName;
  Map<String, Object?> toJson() => {'url': url, 'name': channelName};
}

final leagueProfileKeyProvider = Provider<String>(
  (ref) =>
      '${ref.watch(profileUserIdProvider) ?? 'local'}_${ref.watch(activeProfileProvider)?.id ?? 'default'}',
);

final leagueFavoritesProvider =
    AsyncNotifierProvider.family<
      LeagueFavoritesNotifier,
      Map<String, LeagueChoice>,
      String
    >(LeagueFavoritesNotifier.new);

class LeagueFavoritesNotifier extends AsyncNotifier<Map<String, LeagueChoice>> {
  LeagueFavoritesNotifier(this.profileKey);
  final String profileKey;
  Future<void> _writes = Future.value();
  String get _key => 'favorite_leagues_v1_$profileKey';
  @override
  Future<Map<String, LeagueChoice>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return {'laliga': const LeagueChoice()};
    try {
      final values = jsonDecode(raw) as Map<String, dynamic>;
      return values.map(
        (id, row) => MapEntry(
          id,
          LeagueChoice(
            url: row['url'] as String?,
            channelName: row['name'] as String?,
          ),
        ),
      );
    } catch (_) {
      return {'laliga': const LeagueChoice()};
    }
  }

  Future<void> save(String id, LeagueChoice? choice) async {
    // Serialise edits too: simultaneous pins must not overwrite one another.
    final previous = _writes;
    _writes = () async {
      await previous.catchError((_) {});
      final current = await future;
      if (!ref.mounted) return;
      final next = Map<String, LeagueChoice>.of(current);
      if (choice == null) {
        next.remove(id);
      } else {
        next[id] = choice;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(next.map((id, value) => MapEntry(id, value.toJson()))),
      );
      if (ref.mounted) state = AsyncData(next);
    }();
    await _writes;
  }
}
