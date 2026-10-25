import 'package:shared_preferences/shared_preferences.dart';

Future<void> clearImageCache() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('cache_cleared_v223') ?? false) return;

  final keys = prefs.getKeys();
  for (String key in keys) {
    if (key.startsWith('img_cache_')) {
      await prefs.remove(key);
    }
  }
  await prefs.setBool('cache_cleared_v223', true);
}
