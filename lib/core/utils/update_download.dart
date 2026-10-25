import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

bool isNewerVersion(String current, String latest) {
  List<int>? parts(String value) {
    final pieces = value.split('+').first.split('.');
    if (pieces.length != 3) return null;
    final numbers = pieces.map(int.tryParse).toList();
    if (numbers.any((p) => p == null || p < 0)) return null;
    return numbers.cast<int>();
  }

  final a = parts(current), b = parts(latest);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return b[i] > a[i];
  }
  return false;
}

/// Only publish a local installer after HTTPS, status and digest validation.
Future<File> downloadUpdate(
  Uri uri,
  File destination,
  String digest, {
  http.Client? client,
}) async {
  if (uri.scheme != 'https' || !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(digest)) {
    throw StateError(
      'La actualización no incluye una descarga HTTPS verificable.',
    );
  }
  final connection = client ?? http.Client();
  final partial = File('${destination.path}.part');
  try {
    final response = await connection
        .get(uri)
        .timeout(const Duration(minutes: 3));
    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      throw StateError('No se pudo descargar el instalador.');
    }
    if (sha256.convert(response.bodyBytes).toString() != digest.toLowerCase()) {
      throw StateError('La descarga no supera la comprobación de integridad.');
    }
    await partial.writeAsBytes(response.bodyBytes, flush: true);
    if (await destination.exists()) await destination.delete();
    return await partial.rename(destination.path);
  } finally {
    if (client == null) connection.close();
    if (await partial.exists()) await partial.delete();
  }
}
