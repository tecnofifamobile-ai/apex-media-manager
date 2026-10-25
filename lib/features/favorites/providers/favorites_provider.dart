import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../../core/models/favorite_channel.dart';

class FavoritesNotifier extends Notifier<List<FavoriteChannel>> {
  late Future<void> _ready;
  Future<void> _writes = Future.value();
  @override
  List<FavoriteChannel> build() {
    _ready = _load();
    return [];
  }

  Future<void> _load() async {
    final database = isar;
    List<FavoriteChannel> values;
    if (database != null) {
      values = await database.favoriteChannels.where().findAll();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final rows =
          jsonDecode(prefs.getString('compatible_favorites') ?? '[]') as List;
      values = rows
          .map(
            (row) => FavoriteChannel()
              ..cleanName = row['name'] as String
              ..addedAt = DateTime.parse(row['added'] as String)
              ..category = row['category'] as String
              ..preferredUrl = row['url'] as String?
              ..preferredName = row['preferred_name'] as String?,
          )
          .toList();
    }
    if (ref.mounted) state = values;
  }

  Future<void> _persist(List<FavoriteChannel> snapshot) async {
    final database = isar;
    if (database != null) {
      await database.writeTxn(() async {
        await database.favoriteChannels.clear();
        await database.favoriteChannels.putAll(snapshot);
      });
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'compatible_favorites',
        jsonEncode(
          snapshot
              .map(
                (f) => {
                  'name': f.cleanName,
                  'added': f.addedAt.toIso8601String(),
                  'category': f.category,
                  'url': f.preferredUrl,
                  'preferred_name': f.preferredName,
                },
              )
              .toList(),
        ),
      );
    }
  }

  Future<void> _save(List<FavoriteChannel> values) async {
    state = values;
    final snapshot = List<FavoriteChannel>.of(values);
    _writes = _writes.catchError((_) {}).then((_) => _persist(snapshot));
    await _writes;
  }

  Future<void> toggleFavorite(
    String cleanName, {
    String category = 'General',
  }) async {
    await _ready;
    if (!ref.mounted) return;
    if (state.any((f) => f.cleanName == cleanName)) {
      await _save(state.where((f) => f.cleanName != cleanName).toList());
    } else {
      await _save([
        ...state,
        FavoriteChannel()
          ..cleanName = cleanName
          ..addedAt = DateTime.now()
          ..category = category,
      ]);
    }
  }

  Future<void> setCategory(String cleanName, String category) async {
    await _ready;
    if (!ref.mounted) return;
    final values = state
        .map(
          (f) => _copy(
            f,
            category: f.cleanName == cleanName ? category : f.category,
          ),
        )
        .toList();
    await _save(values);
  }

  Future<void> updatePreferred(
    String cleanName,
    String url,
    String name,
  ) async {
    await _ready;
    if (!ref.mounted) return;
    await _save(
      state
          .map(
            (f) =>
                f.cleanName == cleanName ? _copy(f, url: url, name: name) : f,
          )
          .toList(),
    );
  }

  FavoriteChannel _copy(
    FavoriteChannel f, {
    String? category,
    String? url,
    String? name,
  }) => FavoriteChannel()
    ..id = f.id
    ..cleanName = f.cleanName
    ..addedAt = f.addedAt
    ..category = category ?? f.category
    ..preferredUrl = url ?? f.preferredUrl
    ..preferredName = name ?? f.preferredName;
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<FavoriteChannel>>(
      FavoritesNotifier.new,
    );
final favoriteCategoriesProvider = Provider<List<String>>((ref) {
  final categories = ref
      .watch(favoritesProvider)
      .map((f) => f.category)
      .toSet()
      .toList();
  return categories.isEmpty ? ['General'] : categories;
});
