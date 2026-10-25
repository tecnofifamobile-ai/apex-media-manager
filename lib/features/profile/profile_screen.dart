import '../../core/widgets/ios_spinner.dart';
import '../../core/widgets/remote_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/profile_provider.dart';
import 'widgets/add_profile_dialog.dart';
import '../../core/utils/wallpaper_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profilesProvider);
    final wallpaper = ref.watch(wallpaperProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo oscuro unificado de la app
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: Image.asset(
                wallpaper,
                key: ValueKey(wallpaper),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          // Capa de opacidad para mejorar contraste
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const Text(
                "Who's watching?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: profilesAsync.when(
                  data: (profiles) => GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 210,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 24,
                        ),
                    itemCount: profiles.length + 1,
                    itemBuilder: (context, index) {
                      if (index == profiles.length) {
                        return _buildNewProfileButton();
                      }
                      final profile = profiles[index];
                      return _buildProfileAvatar(
                        autofocus: index == 0,
                        name: profile.name,
                        color: Color(profile.colorCode),
                        size: 120,
                        onTap: () {
                          ref
                              .read(activeProfileProvider.notifier)
                              .setProfile(profile);
                          context.go('/channels');
                        },
                      );
                    },
                  ),
                  loading: () =>
                      const Center(child: IosSpinner()),
                  error: (_, _) => const Center(
                    child: Text('No se pudieron cargar los perfiles.'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar({
    bool autofocus = false,
    required String name,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return _HoverAvatar(
      name: name,
      color: color,
      size: size,
      onTap: onTap,
      autofocus: autofocus,
    );
  }

  Widget _buildNewProfileButton() {
    return _HoverAvatar(
      autofocus: ref.read(profilesProvider).value?.isEmpty ?? false,
      name: 'New profile',
      color: Colors.white.withValues(alpha: 0.05),
      size: 110,
      icon: Icons.add,
      onTap: () {
        _showAddProfileDialog(context);
      },
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddProfileDialog(),
    );
  }
}

class _HoverAvatar extends StatefulWidget {
  final bool autofocus;
  final String name;
  final Color color;
  final double size;
  final IconData? icon;
  final VoidCallback onTap;

  const _HoverAvatar({
    this.autofocus = false,
    required this.name,
    required this.color,
    required this.size,
    this.icon,
    required this.onTap,
  });

  @override
  State<_HoverAvatar> createState() => _HoverAvatarState();
}

class _HoverAvatarState extends State<_HoverAvatar> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          cursor: SystemMouseCursors.click,
          child: RemoteAction(
            autofocus: widget.autofocus,
            label: widget.name,
            onTap: widget.onTap,
            child: AnimatedContainer(
              width: widget.size,
              height: widget.size,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutExpo,
              transform: isHovered
                  ? (Matrix4.identity()..scaleByDouble(1.05, 1.05, 1.0, 1.0))
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: .28),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isHovered
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.white12,
                  width: isHovered ? 3 : 0,
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: widget.icon != null
                  ? Center(
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: widget.size * 0.35,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.name,
          style: TextStyle(
            color: isHovered ? Colors.white : Colors.white70,
            fontSize: 16,
            fontWeight: isHovered ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
