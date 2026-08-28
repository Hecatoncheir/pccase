import 'package:flutter/material.dart';

import '../../theme/mod_colors.dart';
import 'magnetic.dart';
import 'pointer_field.dart';

enum ModButtonStyle { solid, ghost }

/// Кнопка с магнитной зоной: тянется к курсору ещё до наведения
/// и плавно возвращается на место, когда он уходит. Подпись едет чуть
/// дальше корпуса — за счёт этого притяжение читается сильнее, чем оно есть.
class ModButton extends StatelessWidget {
  const ModButton({
    required this.label,
    required this.onPressed,
    this.style = ModButtonStyle.solid,
    this.compact = false,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final ModButtonStyle style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final solid = style == ModButtonStyle.solid;

    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 22,
        vertical: compact ? 9 : 13,
      ),
      decoration: BoxDecoration(
        gradient: solid ? c.ramp : null,
        borderRadius: BorderRadius.circular(999),
        border: solid ? null : Border.all(color: c.line),
      ),
      child: _MagneticLabel(
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: solid ? const Color(0xFF0A0A0C) : c.ink,
            fontSize: compact ? 11.5 : 12.5,
          ),
        ),
      ),
    );

    return Magnetic(
      padding: compact ? 34 : 44,
      movement: 0.42,
      maxTravel: compact ? 14 : 22,
      builder: (context, pull, child) => Transform.translate(
        offset: pull,
        child: _PullScope(pull: pull, child: child),
      ),
      child: HotZone(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(999),
            mouseCursor: MouseCursor.defer,
            child: body,
          ),
        ),
      ),
    );
  }
}

/// Пробрасывает смещение внутрь кнопки, чтобы подпись могла уехать дальше
/// корпуса, не пересчитывая зону заново.
class _PullScope extends InheritedWidget {
  const _PullScope({required this.pull, required super.child});

  final Offset pull;

  static Offset of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PullScope>()?.pull ??
      Offset.zero;

  @override
  bool updateShouldNotify(_PullScope oldWidget) => oldWidget.pull != pull;
}

class _MagneticLabel extends StatelessWidget {
  const _MagneticLabel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Transform.translate(offset: _PullScope.of(context) * 0.3, child: child);
}
