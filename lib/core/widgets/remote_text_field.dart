import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/device_capabilities.dart';
import 'remote_action.dart';

/// On TV, moving focus highlights the field; OK opens the keyboard.
class RemoteTextField extends StatefulWidget {
  const RemoteTextField({
    super.key,
    this.controller,
    this.style,
    this.decoration = const InputDecoration(),
    this.obscureText = false,
    this.onChanged,
    this.minLines,
    this.maxLines = 1,
  });
  final TextEditingController? controller;
  final TextStyle? style;
  final InputDecoration decoration;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final int? minLines, maxLines;
  @override
  State<RemoteTextField> createState() => _RemoteTextFieldState();
}

class _RemoteTextFieldState extends State<RemoteTextField> {
  final _editor = FocusNode();
  final _navigation = FocusNode();
  bool _editing = false;
  void _begin() {
    if (_editing) return;
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editor.requestFocus();
    });
  }

  void _finish() {
    setState(() => _editing = false);
    _navigation.requestFocus();
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
  }

  @override
  void dispose() {
    _editor.dispose();
    _navigation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tv = DeviceCapabilities.isTv;
    final field = TextField(
      controller: widget.controller,
      focusNode: _editor,
      canRequestFocus: !tv || _editing,
      style: widget.style,
      decoration: widget.decoration,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      textInputAction: widget.maxLines == 1
          ? TextInputAction.done
          : TextInputAction.newline,
      onEditingComplete: tv && widget.maxLines == 1 ? _finish : null,
    );
    if (!tv) return field;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, event) {
        if (_editing &&
            event is KeyDownEvent &&
            [
              LogicalKeyboardKey.arrowDown,
              LogicalKeyboardKey.arrowUp,
            ].contains(event.logicalKey)) {
          _finish();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _navigation.focusInDirection(
                event.logicalKey == LogicalKeyboardKey.arrowDown
                    ? TraversalDirection.down
                    : TraversalDirection.up,
              );
            }
          });
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: RemoteAction(
        focusNode: _navigation,
        label: widget.decoration.hintText,
        onTap: _begin,
        child: IgnorePointer(ignoring: !_editing, child: field),
      ),
    );
  }
}
