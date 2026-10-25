import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static Directory? _cacheDir;

  static Future<void> init() async {
    if (_cacheDir == null) {
      final tempDir = await getTemporaryDirectory();
      _cacheDir = Directory('${tempDir.path}/iptv_logos');
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    }
  }

  static String _getFileName(String url) {
    final bytes = utf8.encode(url);
    final b64 = base64UrlEncode(bytes);
    return b64.replaceAll('=', '') + '.png';
  }

  static Future<File?> getCachedFile(String url) async {
    if (url.isEmpty) return null;
    await init();
    final file = File('${_cacheDir!.path}/${_getFileName(url)}');
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  static Future<File?> downloadFile(String url, {bool useVlc = false}) async {
    if (url.isEmpty) return null;
    await init();
    final file = File('${_cacheDir!.path}/${_getFileName(url)}');
    
    if (await file.exists()) {
      return file;
    }

    try {
      final headers = useVlc ? {
        'User-Agent': 'VLC/3.0.16 LibVLC/3.0.16',
        'Accept': 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
      } : <String, String>{};
      
      final response = await http.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.bodyBytes.length > 300) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> preloadImages(List<String> urls) async {
    await init();
    // Preload concurrently in batches
    final batchSize = 10;
    for (int i = 0; i < urls.length; i += batchSize) {
      final end = (i + batchSize < urls.length) ? i + batchSize : urls.length;
      final batch = urls.sublist(i, end);
      await Future.wait(batch.map((url) => downloadFile(url)));
    }
  }
}
