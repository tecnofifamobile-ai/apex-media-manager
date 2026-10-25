import 'package:flutter/widgets.dart';

class FloatingShellInsets extends InheritedWidget {
  const FloatingShellInsets({
    super.key,
    required this.insets,
    required super.child,
  });
  final EdgeInsets insets;
  static EdgeInsets? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FloatingShellInsets>()?.insets;
  @override
  bool updateShouldNotify(FloatingShellInsets oldWidget) =>
      oldWidget.insets != insets;
}
