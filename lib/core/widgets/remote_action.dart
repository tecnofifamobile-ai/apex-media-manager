import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pointer and remote activation share the same action and visible focus state.
class RemoteAction extends StatefulWidget {
  const RemoteAction({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.onDoubleTap,
    this.behavior = HitTestBehavior.opaque,
    this.autofocus = false,
    this.onFocusChange,
    this.label,
    this.focusNode,
  });

  final Widget child;
  final VoidCallback? onTap, onLongPress, onSecondaryTap, onDoubleTap;
  final HitTestBehavior behavior;
  final bool autofocus;
  final ValueChanged<bool>? onFocusChange;
  final String? label;
  final FocusNode? focusNode;

  @override
  State<RemoteAction> createState() => _RemoteActionState();
}

class _RemoteActionState extends State<RemoteAction> {
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        enabled: widget.onTap != null,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.contextMenu): _OptionsIntent(),
          SingleActivator(LogicalKeyboardKey.gameButtonY): _OptionsIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
          _OptionsIntent: CallbackAction<_OptionsIntent>(
            onInvoke: (_) {
              (widget.onLongPress ?? widget.onSecondaryTap)?.call();
              return null;
            },
          ),
        },
        onFocusChange: (focused) {
          setState(() => _focused = focused);
          widget.onFocusChange?.call(focused);
          if (focused) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Scrollable.ensureVisible(
                  context,
                  duration: const Duration(milliseconds: 120),
                  alignmentPolicy:
                      ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                );
              }
            });
          }
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: widget.onTap == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: widget.behavior,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onSecondaryTap: widget.onSecondaryTap,
            onDoubleTap: widget.onDoubleTap,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focused
                      ? Colors.white.withValues(alpha: .85)
                      : _hovered
                      ? Colors.white24
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionsIntent extends Intent {
  const _OptionsIntent();
}
