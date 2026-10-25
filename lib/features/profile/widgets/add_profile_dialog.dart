import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../../../core/models/profile_model.dart';

class AddProfileDialog extends ConsumerStatefulWidget {
  const AddProfileDialog({super.key});

  @override
  ConsumerState<AddProfileDialog> createState() => _AddProfileDialogState();
}

class _AddProfileDialogState extends ConsumerState<AddProfileDialog> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _m3uEpgUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  ProfileType _selectedType = ProfileType.m3u;

  // Lista de colores seleccionables para el avatar
  final List<Color> _availableColors = [
    const Color(0xFFFFAAA5), // Rosa
    const Color(0xFF5A67D8), // Morado/Azul
    const Color(0xFF48BB78), // Verde
    const Color(0xFFF6AD55), // Naranja
  ];
  
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _availableColors[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) return;

    if (_selectedType == ProfileType.m3u) {
      if (url.isNotEmpty) {
        ref.read(profilesProvider.notifier).addM3uProfile(name, url, _m3uEpgUrlController.text.trim(), _selectedColor.value);
        Navigator.of(context).pop();
      }
    } else {
      if (url.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
        ref.read(profilesProvider.notifier).addXcProfile(name, username, password, url, _selectedColor.value);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Profile',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              
              // Tipo de conexión
              Row(
                children: [
                  _buildTypeButton('M3U Playlist', ProfileType.m3u),
                  const SizedBox(width: 12),
                  _buildTypeButton('Xtream Codes', ProfileType.xtreamCodes),
                ],
              ),
              const SizedBox(height: 24),
              
              // Name input
              _buildLabel('Profile Name'),
              _buildTextField(_nameController, 'e.g. My Family, Sports...'),
              const SizedBox(height: 16),

              // Host/URL input
              _buildLabel(_selectedType == ProfileType.m3u ? 'M3U Playlist URL' : 'Server Host URL'),
              _buildTextField(_urlController, 'http://example.com:8080'),
              const SizedBox(height: 16),

              // XC Credentials
              if (_selectedType == ProfileType.xtreamCodes) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Username'),
                          _buildTextField(_usernameController, 'Username'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Password'),
                          _buildTextField(_passwordController, 'Password', obscureText: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Color picker
              _buildLabel('Avatar Color'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _availableColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save Profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }

  Widget _buildTypeButton(String text, ProfileType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? Colors.white.withOpacity(0.5) : Colors.white12),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white12)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white38)),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
      ),
    );
  }
}
