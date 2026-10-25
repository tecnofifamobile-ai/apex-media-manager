import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/wallpaper_provider.dart';

/// Frosted surfaces share the same light, borders and corner geometry.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 24,
    this.blur = false,
    this.grouped = false,
    this.padding = EdgeInsets.zero,
  });
  final Widget child;
  final double radius;
  final bool blur;
  final bool grouped;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) {
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x24FFFFFF), Color(0x0CFFFFFF)],
        ),
        border: Border.all(color: const Color(0x24FFFFFF)),
      ),
      child: Padding(padding: padding, child: child),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: blur
          ? grouped
                ? BackdropFilter.grouped(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: surface,
                  )
                : BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: surface,
                  )
          : surface,
    );
  }
}

class GlassBackground extends ConsumerWidget {
  const GlassBackground({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Stack(
    children: [
      Positioned.fill(
        child: RepaintBoundary(
          child: Image.asset(
            ref.watch(wallpaperProvider),
            fit: BoxFit.cover,
            cacheWidth: 1600,
          ),
        ),
      ),
      const Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x85080A14), Color(0x30080A14), Color(0xC5080A14)],
            ),
          ),
        ),
      ),
      child,
    ],
  );
}

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({super.key, required this.body, this.appBar});
  final Widget body;
  final PreferredSizeWidget? appBar;
  @override
  Widget build(BuildContext context) => GlassBackground(
    child: BackdropGroup(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
      ),
    ),
  );
}

class GlassTile extends StatelessWidget {
  const GlassTile({
    super.key,
    this.leading,
    this.trailing,
    this.title,
    this.onTap,
    this.autofocus = false,
  });
  final Widget? leading, trailing, title;
  final VoidCallback? onTap;
  final bool autofocus;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: GlassSurface(
      radius: 18,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: leading,
          trailing: trailing,
          title: title,
          onTap: onTap,
          autofocus: autofocus,
        ),
      ),
    ),
  );
}

/// Compact content-sized sheet rather than an opaque Material alert.
class GlassDialog extends StatelessWidget {
  const GlassDialog({super.key, this.title, this.content, this.actions});
  final Widget? title, content;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 520,
        maxHeight: MediaQuery.sizeOf(context).height * .84,
      ),
      child: GlassSurface(
        blur: true,
        radius: 30,
        child: Material(
          color: const Color(0x9A111421),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null)
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 23,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    child: title!,
                  ),
                if (content != null) ...[
                  const SizedBox(height: 22),
                  Flexible(fit: FlexFit.loose, child: content!),
                ],
                if (actions?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 10,
                    runSpacing: 8,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
