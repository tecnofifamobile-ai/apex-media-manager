import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class UpdaterService {
  static Future<void> checkForUpdates(BuildContext context) async {
    try {
      final response = await Supabase.instance.client
          .from('app_settings')
          .select('latest_version, apk_url, windows_exe_url, release_notes')
          .maybeSingle();

      if (response == null) return;

      final latestVersion = response['latest_version'] as String;
      final apkUrl = response['apk_url'] as String;
      final windowsExeUrl = response['windows_exe_url'] as String?;
      final releaseNotes = response['release_notes'] as String?;

      final updateUrl = Platform.isWindows ? windowsExeUrl : apkUrl;

      if (updateUrl == null || updateUrl.isEmpty) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewer(currentVersion, latestVersion)) {
        if (context.mounted) {
          _showUpdateDialog(context, latestVersion, updateUrl, releaseNotes ?? 'A new version is available.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTA Check Error: $e'), backgroundColor: Colors.red));
      }
      print('Failed to check for updates: $e');
    }
  }

  static bool _isNewer(String current, String latest) {
    try {
      current = current.split('+')[0];
      latest = latest.split('+')[0];
      List<int> currParts = current.split('.').map(int.parse).toList();
      List<int> latestParts = latest.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        int c = i < currParts.length ? currParts[i] : 0;
        int l = i < latestParts.length ? latestParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static void _showUpdateDialog(BuildContext context, String version, String apkUrl, String notes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Update Available ($version)', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(notes.replaceAll('\\n', '\n'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Later', style: TextStyle(color: Colors.white54)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _downloadAndInstall(context, apkUrl);
                          },
                          child: const Text('Update Now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _downloadAndInstall(BuildContext context, String url) async {
    // Show downloading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              ),
              padding: const EdgeInsets.all(32),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 24),
                  Text('Downloading update...', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final response = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      
      final fileName = Platform.isWindows ? 'update.exe' : 'update.apk';
      final file = File('${dir.path}/$fileName');
      
      await file.writeAsBytes(response.bodyBytes);

      if (context.mounted) {
        Navigator.pop(context); // Close downloading dialog
      }

      // Trigger APK or EXE installation
      await OpenFilex.open(file.path);
      
      if (Platform.isWindows) {
        exit(0);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download update: $e')),
        );
      }
    }
  }
}
