import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:esptv_player/features/vpn/warp_service.dart';

void main() {
  test('WARP registration uses a unique device key for each request', () async {
    final keys = <String>[];
    final mock = MockClient((request) async {
      final payload = jsonDecode(request.body);
      keys.add(payload['key'] as String);
      return http.Response(
        jsonEncode({
          'config': {
            'interface': {
              'addresses': {'v4': '172.16.0.2', 'v6': '2606:4700::1'},
            },
            'peers': [
              {
                'public_key': base64Encode(List.filled(32, 1)),
                'endpoint': {'v4': '162.159.192.1:2408'},
              },
            ],
          },
        }),
        201,
      );
    });
    final first = await WarpService.register(client: mock);
    final second = await WarpService.register(client: mock);
    expect(first.privateKey, isNot(second.privateKey));
    expect(keys[0], isNot(keys[1]));
    WarpService.validateConfiguration(first.toWireguardConf());
    expect(WarpService.endpoint(first.toWireguardConf()), '162.159.192.1:2408');
    expect(
      () => WarpService.validateConfiguration(
        '${first.toWireguardConf()}\nPostUp = arbitrary-command',
      ),
      throwsFormatException,
    );
  });
}
