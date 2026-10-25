import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/io_client.dart';
import 'package:esptv_player/features/iptv_parser/m3u_parser.dart';

void main() {
  late HttpServer server;
  final certificate = File('test/fixtures/tls/localhost-cert.pem');
  final key = File('test/fixtures/tls/localhost-key.pem');
  setUp(() async {
    final context = SecurityContext()
      ..useCertificateChainBytes(await certificate.readAsBytes())
      ..usePrivateKeyBytes(await key.readAsBytes());
    server = await HttpServer.bindSecure(
      InternetAddress.loopbackIPv4,
      0,
      context,
    );
    server.listen((request) {
      request.response.write('ok');
      request.response.close();
    });
  });
  tearDown(() => server.close(force: true));

  test(
    'untrusted self-signed HTTPS is rejected by the default client',
    () async {
      final client = IOClient();
      addTearDown(client.close);
      await expectLater(
        client.get(Uri.parse('https://localhost:${server.port}')),
        throwsA(isA<Exception>()),
      );
    },
  );
  test('explicitly trusted HTTPS remains usable', () async {
    final trust = SecurityContext()
      ..setTrustedCertificatesBytes(await certificate.readAsBytes());
    final client = IOClient(HttpClient(context: trust));
    addTearDown(client.close);
    expect(
      (await client.get(Uri.parse('https://localhost:${server.port}'))).body,
      'ok',
    );
  });
  test('a trusted certificate still rejects a hostname mismatch', () async {
    final trust = SecurityContext()
      ..setTrustedCertificatesBytes(await certificate.readAsBytes());
    final client = IOClient(HttpClient(context: trust));
    addTearDown(client.close);
    await expectLater(
      client.get(Uri.parse('https://127.0.0.1:${server.port}')),
      throwsA(isA<Exception>()),
    );
  });
  test('cleartext IPTV lists remain supported', () async {
    final plain = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => plain.close(force: true));
    plain.listen((request) {
      request.response.write(
        '#EXTM3U\n#EXTINF:-1 group-title="Test",Test HD\nhttp://localhost/live.ts\n',
      );
      request.response.close();
    });
    final channels = await M3uParser().parseFromUrl(
      'http://127.0.0.1:${plain.port}/list',
    );
    expect(channels.single.name, 'Test HD');
    expect(channels.single.url, 'http://localhost/live.ts');
  });
  test('application startup installs no certificate bypass', () {
    final source = File('lib/main.dart').readAsStringSync();
    expect(source, isNot(contains('HttpOverrides.global')));
    expect(source, isNot(contains('badCertificateCallback')));
  });
}
