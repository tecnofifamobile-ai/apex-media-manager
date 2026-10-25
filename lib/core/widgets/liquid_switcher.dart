import 'package:flutter/material.dart';

import 'glass.dart';
import 'remote_action.dart';

class LiquidSegment<T> {
  const LiquidSegment(
    this.value,
    this.label,
    this.icon, {
    this.showIcon = false,
  });
  final T value;
  final String label;
  final IconData icon;
  final bool showIcon;
}

/// Native counterpart of the 21st.dev glass switcher: one sliding optical lens.
class LiquidSwitcher<T> extends StatefulWidget {
  const LiquidSwitcher({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
    this.iconsOnly = false,
    this.height = 48,
  });
  final List<LiquidSegment<T>> segments;
  final T value;
  final ValueChanged<T> onChanged;
  final bool iconsOnly;
  final double height;
  @override
  State<LiquidSwitcher<T>> createState() => _LiquidSwitcherState<T>();
}

class _LiquidSwitcherState<T> extends State<LiquidSwitcher<T>> {
  int? _dragIndex;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final count = widget.segments.length;
      final selected = widget.segments.indexWhere(
        (s) => s.value == widget.value,
      );
      final index = _dragIndex ?? (selected < 0 ? 0 : selected);
      return GlassSurface(
        radius: 100,
        blur: true,
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          onHorizontalDragUpdate: (event) {
            final next = (event.localPosition.dx / ((box.maxWidth - 8) / count))
                .floor()
                .clamp(0, count - 1);
            if (_dragIndex != next) setState(() => _dragIndex = next);
          },
          onHorizontalDragCancel: () => setState(() => _dragIndex = null),
          onHorizontalDragEnd: (_) {
            final next = _dragIndex;
            setState(() => _dragIndex = null);
            if (next != null) widget.onChanged(widget.segments[next].value);
          },
          child: SizedBox(
            height: widget.height - 8,
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: Alignment(
                    count == 1 ? 0 : -1 + 2 * index / (count - 1),
                    0,
                  ),
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  child: FractionallySizedBox(
                    widthFactor: 1 / count,
                    heightFactor: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x50FFFFFF),
                            Color(0x12FFFFFF),
                            Color(0x25FFFFFF),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0x55FFFFFF),
                          width: .8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x30000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(count, (i) {
                    final item = widget.segments[i];
                    final active = i == index;
                    return Expanded(
                      child: Tooltip(
                        message: item.label,
                        child: RemoteAction(
                          label: item.label,
                          onTap: () => widget.onChanged(item.value),
                          child: Center(
                            child: widget.iconsOnly || item.showIcon
                                ? Icon(
                                    item.icon,
                                    size: 19,
                                    color: active
                                        ? Colors.white
                                        : Colors.white54,
                                  )
                                : Text(
                                    item.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: active
                                          ? Colors.white
                                          : Colors.white54,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
