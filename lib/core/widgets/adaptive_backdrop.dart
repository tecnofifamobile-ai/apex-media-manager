import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../utils/device_capabilities.dart';

/// Avoid repeated GPU backdrop passes on television hardware.
class AdaptiveBackdrop extends StatelessWidget {
  const AdaptiveBackdrop({
    super.key,
    required this.filter,
    required this.child,
  });
  final ImageFilter filter;
  final Widget child;

  @override
  Widget build(BuildContext context) => DeviceCapabilities.isTv
      ? ColoredBox(color: const Color(0xF2161927), child: child)
      : BackdropFilter(filter: filter, child: child);
}
