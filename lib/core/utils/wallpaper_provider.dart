import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return 'assets/images/bg_livetv.png';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('app_wallpaper') ?? 'assets/images/bg_livetv.png';
  }

  Future<void> setWallpaper(String path) async {
    state = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_wallpaper', path);
  }
}

final wallpaperProvider = NotifierProvider<WallpaperNotifier, String>(() {
  return WallpaperNotifier();
});
