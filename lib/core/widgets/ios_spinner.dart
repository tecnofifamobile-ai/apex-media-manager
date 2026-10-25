import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IosSpinner extends StatelessWidget {
  const IosSpinner({
    super.key,
    this.color,
    this.strokeWidth = 2,
    this.radius = 12,
  });
  final Color? color;
  final double strokeWidth, radius;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Cargando',
    child: CupertinoActivityIndicator(
      radius: radius,
      color: color ?? Colors.white70,
      animating: !MediaQuery.disableAnimationsOf(context),
    ),
  );
}
