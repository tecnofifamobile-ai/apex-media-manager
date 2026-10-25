import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/profile_provider.dart';
import 'widgets/add_profile_dialog.dart';
import '../../core/models/profile_model.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _dontAskAgain = false;

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profilesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 48),
            
            // Who's watching
            const Text(
              "Who's watching?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            profilesAsync.when(
              data: (profiles) => Row(
                children: [
                  ...profiles.map((profile) => Padding(
                    padding: const EdgeInsets.only(right: 24.0),
                    child: _buildProfileAvatar(
                      name: profile.name,
                      color: Color(profile.colorCode),
                      size: 80,
                      onTap: () {
                        ref.read(activeProfileProvider.notifier).setProfile(profile);
                        context.go('/channels');
                      },
                    ),
                  )),
                  _buildNewProfileButton(),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading profiles', style: TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 48),

            // Account Settings
            const Text(
              "Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildAccountRow(Icons.email_outlined, 'tecnofifamobile@gmail.com', true),
            const SizedBox(height: 16),
            _buildAccountAction(Icons.logout, 'Logout', const Color(0xFF6B4EE6)),
            const SizedBox(height: 16),
            _buildAccountAction(Icons.power_settings_new, 'Logout all devices', const Color(0xFF6B4EE6)),
            const SizedBox(height: 16),
            _buildAccountAction(Icons.delete_forever, 'Delete my account', Colors.redAccent),
            const SizedBox(height: 48),

            // Subscription
            const Text(
              "Subscription",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "You are using the free version of Zen Player.\nTo unlock all features and support me, you can choose a plan below.",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6), // Lighter purple
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Try Zen Access', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountRow(IconData icon, String text, bool showEdit) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (showEdit) const Icon(Icons.edit, color: Colors.white54, size: 20),
      ],
    );
  }

  Widget _buildAccountAction(IconData icon, String text, Color color) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar({required String name, required Color color, required double size, required VoidCallback onTap}) {
    return _HoverAvatar(name: name, color: color, size: size, onTap: onTap);
  }

  Widget _buildNewProfileButton() {
    return _HoverAvatar(
      name: 'New profile',
      color: const Color(0xFF1E2132),
      size: 80,
      icon: Icons.edit_square,
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
            child: AnimatedScale(
              scale: isHovered ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  boxShadow: isHovered
                      ? [BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)]
                      : [],
                ),
                child: widget.icon != null
                    ? Center(child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.3))
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
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
