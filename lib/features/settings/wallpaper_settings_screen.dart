import '../../core/widgets/remote_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/wallpaper_provider.dart';

class WallpaperSettingsScreen extends ConsumerWidget {
  const WallpaperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWallpaper = ref.watch(wallpaperProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0F16),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Fondo de Pantalla',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[...previousChildren, ?currentChild],
              );
            },
            child: Image.asset(
              currentWallpaper,
              key: ValueKey(currentWallpaper),
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0D0F16).withValues(alpha: 0.9),
                  const Color(0xFF0D0F16).withValues(alpha: 0.4),
                  const Color(0xFF0D0F16).withValues(alpha: 0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selecciona un fondo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      _buildWallpaperOption(
                        context,
                        ref,
                        thumbPath: 'assets/images/thumb_blue.jpg',
                        wallpaperPath: 'assets/images/bg_livetv.png',
                        isSelected:
                            currentWallpaper == 'assets/images/bg_livetv.png',
                      ),
                      _buildWallpaperOption(
                        context,
                        ref,
                        thumbPath: 'assets/images/thumb_red.png',
                        wallpaperPath: 'assets/images/bg_red.jpg',
                        isSelected:
                            currentWallpaper == 'assets/images/bg_red.jpg',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperOption(
    BuildContext context,
    WidgetRef ref, {
    required String thumbPath,
    required String wallpaperPath,
    required bool isSelected,
  }) {
    return RemoteAction(
      onTap: () {
        ref.read(wallpaperProvider.notifier).setWallpaper(wallpaperPath);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 4 : 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ]
                : [],
          ),
          child: ClipOval(child: Image.asset(thumbPath, fit: BoxFit.cover)),
        ),
      ),
    );
  }
}
