import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../theme/mod_colors.dart';
import 'pointer_field.dart';

/// Карточка наклоняется вслед за курсором и подсвечивается пятном акцента —
/// тот же приём, что у `.card.tilt` в концепте: rotateX/rotateY от положения
/// указателя внутри карточки плюс блик, идущий за ним.
class TiltCard extends StatefulWidget {
  const TiltCard({required this.child, this.radius = 22, super.key});

  final Widget child;
  final double radius;

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  static const _center = Offset(0.5, 0.5);
  static const _maxTiltX = 7 * math.pi / 180;
  static const _maxTiltY = 9 * math.pi / 180;

  Offset _local = _center;
  bool _hovered = false;

  void _track(PointerHoverEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(event.position);
    setState(() {
      _local = Offset(
        (local.dx / box.size.width).clamp(0.0, 1.0),
        (local.dy / box.size.height).clamp(0.0, 1.0),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final target = _hovered ? _local : _center;

    return HotZone(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _local = _center;
        }),
        onHover: reduceMotion ? null : _track,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: _hovered ? 1 : 0),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          builder: (context, hover, child) => TweenAnimationBuilder<Offset>(
            tween: Tween(end: target),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            builder: (context, tilt, inner) => Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX((0.5 - tilt.dy) * _maxTiltX)
                ..rotateY((tilt.dx - 0.5) * _maxTiltY)
                ..multiply(Matrix4.translationValues(0, -5 * hover, 0)),
              child: inner,
            ),
            child: Stack(
              children: [
                child!,
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: hover,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(widget.radius),
                          border: Border.all(
                            color: c.accent.withValues(alpha: 0.45),
                          ),
                          gradient: RadialGradient(
                            center: Alignment(
                              _local.dx * 2 - 1,
                              _local.dy * 2 - 1,
                            ),
                            radius: 0.8,
                            colors: [
                              c.accent.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
