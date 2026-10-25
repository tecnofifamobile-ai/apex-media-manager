import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final response = await Supabase.instance.client
          .from('app_settings')
          .select('latest_version, apk_url, release_notes')
          .eq('id', 1)
          .maybeSingle();

      if (response == null) return;

      final latestVersion = response['latest_version'] as String?;
      final apkUrl = response['apk_url'] as String?;
      final releaseNotes = response['release_notes'] as String?;

      if (latestVersion == null || apkUrl == null) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isVersionGreater(latestVersion, currentVersion)) {
        _showUpdateDialog(context, latestVersion, apkUrl, releaseNotes ?? 'A new version is available.');
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  static bool _isVersionGreater(String latest, String current) {
    List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int l = i < latestParts.length ? latestParts[i] : 0;
      int c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, String version, String apkUrl, String notes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2132),
        title: const Text('Update Available 🚀', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version $version is ready to download.', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            const Text('Release Notes:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(notes, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4EE6)),
            onPressed: () async {
              final uri = Uri.parse(apkUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Download Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
