import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'device_capabilities.dart';
import 'update_download.dart';

class UpdaterService {
  static bool _checked = false;

  static Future<void> checkForUpdates(BuildContext context) async {
    if (_checked) return;
    _checked = true;
    try {
      final response = await Supabase.instance.client
          .from('app_settings')
          .select()
          .eq('id', 1)
          .maybeSingle()
          .timeout(const Duration(seconds: 8));
      if (response == null) return;
      final current = await PackageInfo.fromPlatform();
      final latest = response['latest_version'] as String?;
      if (latest == null || !isNewerVersion(current.version, latest)) return;
      final abi = DeviceCapabilities.primaryAbi;
      final urls = response['apk_urls'] as Map<String, dynamic>?;
      final hashes = response['apk_sha256s'] as Map<String, dynamic>?;
      final url = Platform.isWindows
          ? response['windows_exe_url']
          : urls?[abi] ?? response['apk_url'];
      final hash = Platform.isWindows
          ? response['windows_sha256']
          : hashes?[abi] ?? response['apk_sha256'];
      if (url is! String || hash is! String || !context.mounted) return;
      final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Actualización $latest'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Text(
              response['release_notes']?.toString() ??
                  'Hay una nueva versión disponible.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Más tarde'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
      if (accepted != true || !context.mounted) return;
      await _install(context, url, hash);
    } catch (_) {
      // Offline operation should never interrupt channel browsing.
      debugPrint('Update service unavailable.');
    }
  }

  static Future<void> _install(
    BuildContext context,
    String url,
    String hash,
  ) async {
    final progress = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 24),
            Expanded(child: Text('Descargando actualización…')),
          ],
        ),
      ),
    );
    final navigator = Navigator.of(context);
    navigator.push(progress);
    try {
      final directory = await getTemporaryDirectory();
      final file = await downloadUpdate(
        Uri.parse(url),
        File(
          '${directory.path}/apex-update.${Platform.isWindows ? "exe" : "apk"}',
        ),
        hash,
      );
      if (progress.isActive) navigator.removeRoute(progress);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        throw StateError('No se pudo abrir el instalador.');
      }
      if (Platform.isWindows) exit(0);
    } catch (_) {
      if (progress.isActive) navigator.removeRoute(progress);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo verificar o instalar la actualización.'),
          ),
        );
      }
    }
  }
}
