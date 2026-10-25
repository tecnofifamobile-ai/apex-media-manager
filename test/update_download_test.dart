import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:esptv_player/core/utils/update_download.dart';

void main() {
  test('compares semantic versions and rejects malformed metadata', () {
    expect(isNewerVersion('2.2.53+1', '2.2.54'), isTrue);
    expect(isNewerVersion('2.2.54', '2.2.9'), isFalse);
    expect(isNewerVersion('2.2.54', '2.2.54'), isFalse);
    expect(isNewerVersion('2.2.54', 'invalid'), isFalse);
  });
  test('failed or altered downloads never publish an installer', () async {
    final directory = await Directory.systemTemp.createTemp(
      'apex-update-test-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/update.apk');
    final digest = sha256.convert([1, 2, 3]).toString();
    for (final response in [
      http.Response('not found', 404),
      http.Response('altered', 200),
    ]) {
      await expectLater(
        downloadUpdate(
          Uri.parse('https://example.com/app'),
          file,
          digest,
          client: MockClient((_) async => response),
        ),
        throwsStateError,
      );
      expect(await file.exists(), isFalse);
    }
    await downloadUpdate(
      Uri.parse('https://example.com/app'),
      file,
      digest,
      client: MockClient((_) async => http.Response.bytes([1, 2, 3], 200)),
    );
    expect(await file.readAsBytes(), [1, 2, 3]);
  });
  test('HTTP update URLs are rejected before making a request', () async {
    await expectLater(
      downloadUpdate(
        Uri.parse('http://example.com/app'),
        File('unused'),
        '0' * 64,
      ),
      throwsStateError,
    );
  });
}
