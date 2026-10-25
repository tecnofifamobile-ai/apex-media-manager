import 'dart:io';

import 'package:flutter/services.dart';

class DeviceCapabilities {
  static bool isTv = false;
  static String primaryAbi = 'arm64-v8a';

  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    try {
      isTv =
          await const MethodChannel('apex/device')
              .invokeMethod<bool>('isTelevision') ??
          false;
      primaryAbi =
          await const MethodChannel('apex/device')
              .invokeMethod<String>('primaryAbi') ??
          primaryAbi;
    } on PlatformException {
      isTv = false;
    } on MissingPluginException {
      isTv = false;
    }
  }
}
