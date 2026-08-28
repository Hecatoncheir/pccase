import 'package:flutter/material.dart';

import '../../theme/mod_colors.dart';
import 'pointer_field.dart';

enum ModButtonStyle { solid, ghost }

/// Кнопка, которая притягивается к курсору в радиусе 110 px —
/// та же магнитная механика, что в концепте.
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

  static const double _radius = 110;

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
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: solid ? const Color(0xFF0A0A0C) : c.ink,
              fontSize: compact ? 11.5 : 12.5,
            ),
      ),
    );

    return _Magnetic(
      radius: _radius,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: body,
        ),
      ),
    );
  }
}

class _Magnetic extends StatefulWidget {
  const _Magnetic({required this.child, required this.radius});

  final Widget child;
  final double radius;

  @override
  State<_Magnetic> createState() => _MagneticState();
}

class _MagneticState extends State<_Magnetic> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Offset>(
      valueListenable: PointerScope.of(context),
      builder: (context, pointer, child) {
        var shift = Offset.zero;
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final center = box.localToGlobal(box.size.center(Offset.zero));
          final delta = pointer - center;
          if (delta.distance < widget.radius) {
            shift = Offset(delta.dx * 0.28, delta.dy * 0.32);
          }
        }
        return Transform.translate(offset: shift, child: child);
      },
      child: widget.child,
    );
  }
}
