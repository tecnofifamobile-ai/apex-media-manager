import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../main.dart';
import '../../../core/models/favorite_channel.dart';

class FavoritesNotifier extends Notifier<List<FavoriteChannel>> {
  @override
  List<FavoriteChannel> build() {
    _loadFavorites();
    return [];
  }

  Future<void> _loadFavorites() async {
    final favs = await isar.favoriteChannels.where().findAll();
    state = favs;
  }

  Future<void> toggleFavorite(String cleanName, {String category = 'General'}) async {
    final existing = await isar.favoriteChannels.where().cleanNameEqualTo(cleanName).findFirst();
    if (existing != null) {
      await isar.writeTxn(() async {
        await isar.favoriteChannels.delete(existing.id);
      });
    } else {
      final newFav = FavoriteChannel()
        ..cleanName = cleanName
        ..addedAt = DateTime.now()
        ..category = category;
      await isar.writeTxn(() async {
        await isar.favoriteChannels.put(newFav);
      });
    }
    _loadFavorites();
  }

  Future<void> setCategory(String cleanName, String newCategory) async {
    final existing = await isar.favoriteChannels.where().cleanNameEqualTo(cleanName).findFirst();
    if (existing != null) {
      existing.category = newCategory;
      await isar.writeTxn(() async {
        await isar.favoriteChannels.put(existing);
      });
      _loadFavorites();
    }
  }

  Future<void> updatePreferred(String cleanName, String preferredUrl, String preferredName) async {
    final existing = await isar.favoriteChannels.where().cleanNameEqualTo(cleanName).findFirst();
    if (existing != null) {
      existing.preferredUrl = preferredUrl;
      existing.preferredName = preferredName;
      await isar.writeTxn(() async {
        await isar.favoriteChannels.put(existing);
      });
      _loadFavorites();
    }
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<FavoriteChannel>>(() {
  return FavoritesNotifier();
});

final favoriteCategoriesProvider = Provider<List<String>>((ref) {
  final favs = ref.watch(favoritesProvider);
  final categories = favs.map((e) => e.category).toSet().toList();
  if (categories.isEmpty) return ['General'];
  return categories;
});
