// Test-only entry point. Production builds always use lib/main.dart.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:esptv_player/main.dart' as app;
import 'package:esptv_player/core/router/app_router.dart';
import 'package:esptv_player/core/utils/device_capabilities.dart';
import 'package:esptv_player/features/auth/local_mode_provider.dart';
import 'package:esptv_player/features/profile/providers/profile_provider.dart';
import 'package:esptv_player/features/iptv_parser/providers/iptv_provider.dart';

Element? findApp(Element root) {
  if (root.widget is app.ESPTVPlayerApp) return root;
  Element? found;
  root.visitChildElements((child) {
    found ??= findApp(child);
  });
  return found;
}

void main() {
  app.main();
  ProviderContainer? container;
  bool busy = false;
  String previous = '';
  Timer.periodic(const Duration(seconds: 2), (_) async {
    if (busy) return;
    busy = true;
    try {
      final root = WidgetsBinding.instance.rootElement;
      if (root == null) return;
      final context = findApp(root);
      if (context == null) return;
      if (container == null) {
        container = ProviderScope.containerOf(context);
        await container!.read(localModeProvider.notifier).enable();
        await container!.read(profilesProvider.future);
        final existing = container!.read(profilesProvider).value ?? [];
        if (!existing.any((p) => p.name == 'QA TV')) {
          await container!
              .read(profilesProvider.notifier)
              .addXcProfile(
                'QA TV',
                'u',
                'p',
                'http://127.0.0.1:8765',
                0xFF5A67D8,
              );
        }
        final profile = container!
            .read(profilesProvider)
            .value!
            .firstWhere((p) => p.name == 'QA TV');
        container!.read(activeProfileProvider.notifier).setProfile(profile);
        container!.read(appRouterProvider).go('/channels');
        debugPrint('APEX_QA_READY television=${DeviceCapabilities.isTv}');
      }
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8765/qa-command'),
      );
      final command = jsonDecode(response.body)['screen'] as String;
      if (command == previous) return;
      previous = command;
      final router = container!.read(appRouterProvider);
      if (command == 'movie') {
        final client = container!.read(xtreamClientProvider)!;
        final movies = await client.getMovies();
        router.pushNamed('player', extra: client.movieChannel(movies.first));
      } else if (command == 'series') {
        final client = container!.read(xtreamClientProvider)!;
        router.go('/series');
        final series = await client.getSeries();
        router.pushNamed('episodes', extra: series.first);
      } else if (command == 'episode') {
        final client = container!.read(xtreamClientProvider)!;
        final episodes = await client.getEpisodes('3');
        router.pushNamed('player', extra: episodes.values.first.first);
      } else {
        router.go('/$command');
      }
      debugPrint('APEX_QA_SCREEN $command');
    } catch (error) {
      debugPrint('APEX_QA_ERROR ${error.runtimeType}');
    } finally {
      busy = false;
    }
  });
}
