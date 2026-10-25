import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalModeNotifier extends Notifier<bool> {
  static bool initiallyEnabled = false;
  @override
  bool build() => initiallyEnabled;
  Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('local_mode', true);
    if (ref.mounted) state = true;
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('local_mode', false);
    if (ref.mounted) state = false;
  }
}

final localModeProvider = NotifierProvider<LocalModeNotifier, bool>(
  LocalModeNotifier.new,
);
