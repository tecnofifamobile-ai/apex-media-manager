import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wireguard_flutter/wireguard_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'warp_service.dart';

final vpnErrorProvider = NotifierProvider<VpnErrorNotifier, String?>(
  () => VpnErrorNotifier(),
);

class VpnErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setError(String? error) => state = error;
}

final vpnLoadingProvider = NotifierProvider<VpnLoadingNotifier, bool>(
  () => VpnLoadingNotifier(),
);

class VpnLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setLoading(bool loading) => state = loading;
}

final vpnEnabledProvider = NotifierProvider<VpnEnabledNotifier, bool>(() {
  return VpnEnabledNotifier();
});

class VpnEnabledNotifier extends Notifier<bool> {
  void _setError(String? err) {
    ref.read(vpnErrorProvider.notifier).setError(err);
  }

  void _setLoading(bool loading) {
    ref.read(vpnLoadingProvider.notifier).setLoading(loading);
  }

  final _wireguard = WireGuardFlutter.instance;
  static const String interfaceName = 'zen_warp';

  @override
  bool build() {
    _init();
    return false;
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('vpn_enabled') ?? false;

    if (isEnabled) {
      try {
        await _wireguard.initialize(interfaceName: interfaceName);
        await enable();
      } catch (e) {
        _setError('Init Error: $e');
      }
    }
  }

  Future<void> toggle() async {
    if (ref.read(vpnLoadingProvider)) return; // Prevent double taps

    _setLoading(true);
    if (state) {
      await disable();
    } else {
      await enable();
    }
    _setLoading(false);
  }

  Future<void> enable() async {
    _setError(null);
    try {
      final prefs = await SharedPreferences.getInstance();

      if ((prefs.getInt('warp_config_version') ?? 0) < 1) {
        await prefs.remove('warp_private_key');
        await prefs.remove('warp_conf');
      }
      String? privateKey = prefs.getString('warp_private_key');
      String? confString = prefs.getString('warp_conf');

      if (privateKey == null || confString == null) {
        try {
          final config = await WarpService.register();
          confString = config.toWireguardConf();
          await prefs.setString('warp_private_key', config.privateKey);
          await prefs.setString('warp_conf', confString);
          await prefs.setInt('warp_config_version', 1);
        } catch (regErr) {
          _setError('API Registration Error: $regErr');
          state = false;
          return;
        }
      }

      await _wireguard.initialize(interfaceName: interfaceName);
      await _wireguard.startVpn(
        serverAddress: WarpService.endpoint(confString),
        wgQuickConfig: confString,
        providerBundleIdentifier: 'com.zen.esptv',
      );

      state = true;
      await prefs.setBool('vpn_enabled', true);
    } catch (e) {
      String errStr = e.toString();
      // Si el error es sobre permisos, damos un mensaje mas claro
      if (errStr.contains('vpn_permission_denied') ||
          errStr.toLowerCase().contains('permission')) {
        _setError(
          'Por favor, acepta la solicitud de conexi\u00F3n VPN de Android para activar Zen Shield.',
        );
      } else {
        _setError('Enable Error: $e');
      }
      state = false;
    }
  }

  Future<void> disable() async {
    try {
      await _wireguard.stopVpn();
      state = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('vpn_enabled', false);
    } catch (e) {
      _setError('Disable Error: $e');
    }
  }

  Future<void> importConfiguration(String config) async {
    WarpService.validateConfiguration(config);
    if (state) {
      await disable();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('warp_conf', config.trim());
    final privateKey = RegExp(
      r'^\s*PrivateKey\s*=\s*(.+)$',
      multiLine: true,
    ).firstMatch(config)!.group(1)!.trim();
    await prefs.setString('warp_private_key', privateKey);
    await prefs.setInt('warp_config_version', 1);
    _setError(null);
  }
}
