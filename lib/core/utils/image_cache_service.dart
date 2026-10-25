import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static Future<Directory>? _directory;
  static final _client = http.Client();
  static final _pending = <String, Future<File?>>{};
  static final _failures = <String, DateTime>{};
  static final _waiting = Queue<Completer<void>>();
  static int _active = 0;

  static Future<Directory> _getDirectory() => _directory ??= () async {
    final temporary = await getTemporaryDirectory();
    return Directory('${temporary.path}/iptv_logos').create(recursive: true);
  }();

  static Future<File?> getCachedFile(String url) async {
    if (url.isEmpty) return null;
    try {
      final directory = await _getDirectory();
      final name = sha256.convert(utf8.encode(url)).toString();
      final file = File('${directory.path}/$name.img');
      return await file.exists() && await file.length() > 0 ? file : null;
    } catch (_) {
      return null;
    }
  }

  static Future<File?> downloadFile(String url, {bool useVlc = false}) async {
    if (url.isEmpty) return null;
    final key = '$url|$useVlc';
    final failed = _failures[key];
    if (failed != null &&
        DateTime.now().difference(failed) < const Duration(minutes: 5)) {
      return null;
    }
    final existing = _pending[url];
    if (existing != null) return existing;
    final future = _download(url, key, useVlc);
    _pending[url] = future;
    try {
      return await future;
    } finally {
      _pending.remove(url);
    }
  }

  static Future<void> _acquire() async {
    if (_active < 6) {
      _active++;
      return;
    }
    final waiter = Completer<void>();
    _waiting.add(waiter);
    await waiter.future;
  }

  static void _release() {
    if (_waiting.isNotEmpty) {
      _waiting.removeFirst().complete();
    } else {
      _active--;
    }
  }

  static Future<File?> _download(String url, String key, bool useVlc) async {
    final cached = await getCachedFile(url);
    if (cached != null) return cached;
    await _acquire();
    try {
      final uri = Uri.tryParse(url);
      if (uri == null || !['http', 'https'].contains(uri.scheme)) return null;
      final response = await _client
          .get(
            uri,
            headers: useVlc ? {'User-Agent': 'VLC/3.0.16 LibVLC/3.0.16'} : {},
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 &&
          response.bodyBytes.isNotEmpty &&
          response.bodyBytes.length < 5 * 1024 * 1024 &&
          !(response.headers['content-type'] ?? '').contains('text/html')) {
        final directory = await _getDirectory();
        final name = sha256.convert(utf8.encode(url)).toString();
        final file = File('${directory.path}/$name.img');
        // A single writer per URL, including user-agent retries.
        await file.writeAsBytes(response.bodyBytes, flush: false);
        return file;
      }
    } catch (_) {
      /* Failed images get a short negative cache. */
    } finally {
      _release();
    }
    if (_failures.length >= 1024) _failures.remove(_failures.keys.first);
    _failures[key] = DateTime.now();
    return null;
  }
}
