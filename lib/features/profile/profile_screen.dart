import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/profile_provider.dart';
import 'widgets/add_profile_dialog.dart';
import '../../core/models/profile_model.dart';
import '../../core/utils/wallpaper_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _dontAskAgain = false;

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
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                "Who's watching?",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profilesAsync.when(
                    data: (profiles) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: profiles.map((profile) => Padding(
                        padding: const EdgeInsets.only(right: 32.0),
                        child: _buildProfileAvatar(
                          name: profile.name,
                          color: Color(profile.colorCode),
                          size: 150,
                          onTap: () {
                            ref.read(activeProfileProvider.notifier).setProfile(profile);
                            context.go('/channels');
                          },
                        ),
                      )).toList(),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.only(right: 32.0),
                      child: SizedBox(
                        width: 150, height: 150,
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                    ),
                    error: (err, stack) => const Padding(
                      padding: EdgeInsets.only(right: 32.0),
                      child: SizedBox(
                        width: 150, height: 150,
                        child: Center(child: Icon(Icons.error_outline, color: Colors.redAccent, size: 50)),
                      ),
                    ),
                  ),
                  _buildNewProfileButton(),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _dontAskAgain,
                    onChanged: (val) => setState(() => _dontAskAgain = val ?? false),
                    side: const BorderSide(color: Colors.white54, width: 1.5),
                    activeColor: Colors.white.withOpacity(0.3),
                    checkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const Text(
                    "Don't ask again",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar({required String name, required Color color, required double size, required VoidCallback onTap}) {
    return _HoverAvatar(name: name, color: color, size: size, onTap: onTap);
  }

  Widget _buildNewProfileButton() {
    return _HoverAvatar(
      name: 'New profile',
      color: Colors.white.withOpacity(0.05),
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
  final String name;
  final Color color;
  final double size;
  final IconData? icon;
  final VoidCallback onTap;

  const _HoverAvatar({
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
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              width: widget.size,
              height: widget.size,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutExpo,
              transform: isHovered
                  ? (Matrix4.identity()..scale(1.05))
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isHovered ? Colors.white.withOpacity(0.8) : Colors.transparent,
                  width: isHovered ? 3 : 0,
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
              ),
              child: widget.icon != null
                  ? Center(child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.35))
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
