import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

class WarpConfig {
  const WarpConfig({required this.privateKey, required this.publicKey,
    required this.peerPublicKey, required this.ipv4, required this.ipv6, required this.endpoint});
  final String privateKey, publicKey, peerPublicKey, ipv4, ipv6, endpoint;
  String toWireguardConf() => '''[Interface]
PrivateKey = $privateKey
Address = ${[ipv4, ipv6].where((v) => v.isNotEmpty).join(', ')}
DNS = 1.1.1.1, 1.0.0.1

[Peer]
PublicKey = $peerPublicKey
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $endpoint
PersistentKeepalive = 25
''';
}

class WarpService {
  /// Generate a unique device key; never ship shared private VPN credentials.
  static Future<WarpConfig> register({http.Client? client}) async {
    final pair = await X25519().newKeyPair();
    final public = base64Encode((await pair.extractPublicKey()).bytes);
    final private = base64Encode(await pair.extractPrivateKeyBytes());
    final connection = client ?? http.Client();
    try {
      final response = await connection.post(
        Uri.parse('https://api.cloudflareclient.com/v0a1922/reg'),
        headers: {'Content-Type': 'application/json', 'User-Agent': 'okhttp/3.12.1', 'CF-Client-Version': 'a-6.3-1922'},
        body: jsonEncode({'key': public, 'fcm_token': '', 'install_id': '',
          'locale': 'es_ES', 'model': 'APEX', 'type': 'Android', 'tos': DateTime.now().toUtc().toIso8601String()}),
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw StateError('No se pudo registrar WARP. Importa una configuración WireGuard propia.');
      }
      final config = jsonDecode(response.body)['config'];
      final peer = (config['peers'] as List).first;
      final addresses = config['interface']['addresses'];
      final ipv4 = addresses['v4'] as String;
      final ipv6 = addresses['v6'] as String? ?? '';
      final result = WarpConfig(privateKey: private, publicKey: public,
        peerPublicKey: peer['public_key'] as String,
        ipv4: ipv4.contains('/') ? ipv4 : '$ipv4/32',
        ipv6: ipv6.isEmpty || ipv6.contains('/') ? ipv6 : '$ipv6/128',
        endpoint: (peer['endpoint']['v4'] ?? peer['endpoint']['host']) as String);
      validateConfiguration(result.toWireguardConf());
      return result;
    } finally { if (client == null) connection.close(); }
  }

  static void validateConfiguration(String config) {
    const allowed = {
      'Interface': {'PrivateKey', 'Address', 'DNS', 'MTU'},
      'Peer': {'PublicKey', 'PresharedKey', 'AllowedIPs', 'Endpoint', 'PersistentKeepalive'},
    };
    String? section;
    final required = <String>{};
    for (var line in const LineSplitter().convert(config)) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      if (line.startsWith('[') && line.endsWith(']')) {
        section = line.substring(1, line.length - 1);
        if (!allowed.containsKey(section)) throw const FormatException('Sección WireGuard no válida.');
        continue;
      }
      final split = line.indexOf('=');
      if (split < 0 || section == null || !allowed[section]!.contains(line.substring(0, split).trim())) {
        throw const FormatException('La configuración contiene una opción no admitida.');
      }
      final name = line.substring(0, split).trim(), value = line.substring(split + 1).trim();
      if (value.isEmpty) throw const FormatException('Falta un valor en la configuración.');
      if (name.endsWith('Key') && base64Decode(value).length != 32) {
        throw const FormatException('Clave WireGuard no válida.');
      }
      required.add('$section.$name');
    }
    if (!required.containsAll(['Interface.PrivateKey', 'Interface.Address', 'Peer.PublicKey', 'Peer.Endpoint', 'Peer.AllowedIPs'])) {
      throw const FormatException('La configuración WireGuard está incompleta.');
    }
  }
  static String endpoint(String config) => RegExp(r'^Endpoint\s*=\s*(.+)$', multiLine: true)
      .firstMatch(config)!.group(1)!.trim();
}
