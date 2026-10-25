import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Preserve the frosted appearance on desktop, mobile and television.
class AdaptiveBackdrop extends StatelessWidget {
  const AdaptiveBackdrop({
    super.key,
    required this.filter,
    required this.child,
  });
  final ImageFilter filter;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      BackdropFilter(filter: filter, child: child);
}
