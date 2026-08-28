import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/case_part.dart';
import '../../state/config_controller.dart';
import '../../theme/mod_colors.dart';
import 'pointer_field.dart';

/// Корпус в 3D на композиции [Matrix4]: шесть граней с общей перспективой,
/// как `transform-style: preserve-3d` в концепте. Наклоняется за курсором,
/// цвета граней приходят из конфигурации.
///
/// Следующий шаг для продакшена — заменить эту сцену на Spline
/// (`HtmlElementView`) или GLB, оставив тот же контракт: цвет детали внутрь,
/// наклон снаружи.
class CasePreview extends ConsumerWidget {
  const CasePreview({this.height = 520, super.key});

  final double height;

  static const double _w = 210;
  static const double _h = 330;
  static const double _halfDepth = 107.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final c = context.mod;

    return SizedBox(
      height: height,
      child: Center(
        child: ValueListenableBuilder<Offset>(
          valueListenable: PointerScope.of(context),
          builder: (context, pointer, _) {
            final box = context.findRenderObject() as RenderBox?;
            var nx = 0.0;
            var ny = 0.0;
            if (box != null && box.hasSize) {
              final center = box.localToGlobal(box.size.center(Offset.zero));
              nx = ((pointer.dx - center.dx) / (box.size.width * 0.9))
                  .clamp(-1.0, 1.0);
              ny = ((pointer.dy - center.dy) / (box.size.height * 0.9))
                  .clamp(-1.0, 1.0);
            }
            final target = Offset(
              (-12 - ny * 13) * math.pi / 180,
              (-28 + nx * 26) * math.pi / 180,
            );

            return TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(end: target),
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              builder: (context, rotation, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)
                  ..rotateX(rotation.dx)
                  ..rotateY(rotation.dy),
                child: child,
              ),
              child: SizedBox(
                width: _w,
                height: _h,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    _floorGlow(c.accent),
                    _plainFace(
                      matrix: Matrix4.translationValues(0, 0, -_halfDepth),
                      size: const Size(_w, _h),
                      color: const Color(0xFF0B0F1A),
                    ),
                    _plainFace(
                      matrix: _rotY(-90).multiplied(_z(105)),
                      size: const Size(215, _h),
                      color: const Color(0xFF141821),
                    ),
                    _ventedTop(config.colorOf(PartId.top)),
                    _glassSide(config.colorOf(PartId.side)),
                    _innerGlow(c.accent, c.accentAlt),
                    _meshFront(config.colorOf(PartId.front)),
                    _leg(config.colorOf(PartId.feet), Matrix4.translationValues(0, 172, 104), 186),
                    _leg(
                      config.colorOf(PartId.feet),
                      Matrix4.translationValues(0, 172, 0).multiplied(
                        _rotY(90).multiplied(_z(102)),
                      ),
                      190,
                    ),
                    _badge(config.colorOf(PartId.badge)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Matrix4 _rotY(double degrees) =>
      Matrix4.rotationY(degrees * math.pi / 180);

  static Matrix4 _z(double distance) =>
      Matrix4.translationValues(0, 0, distance);

  Widget _face({required Matrix4 matrix, required Widget child}) => Transform(
        alignment: Alignment.center,
        transform: matrix,
        child: child,
      );

  Widget _plainFace({
    required Matrix4 matrix,
    required Size size,
    required Color color,
  }) =>
      _face(
        matrix: matrix,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
      );

  Widget _meshFront(Color color) => _face(
        matrix: _z(_halfDepth),
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: color),
          duration: const Duration(milliseconds: 420),
          builder: (context, value, _) => Container(
            width: _w,
            height: _h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
            ),
            child: CustomPaint(painter: _MeshPainter(value ?? color)),
          ),
        ),
      );

  Widget _glassSide(Color tint) => _face(
        matrix: _rotY(90).multiplied(_z(105)),
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: tint),
          duration: const Duration(milliseconds: 420),
          builder: (context, value, _) {
            final glass = value ?? tint;
            return Container(
              width: 215,
              height: _h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: glass.withValues(alpha: 0.6), width: 7),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    glass.withValues(alpha: 0.30),
                    glass.withValues(alpha: 0.07),
                    glass.withValues(alpha: 0.20),
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget _ventedTop(Color color) => _face(
        matrix: Matrix4.rotationX(math.pi / 2).multiplied(_z(165)),
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: color),
          duration: const Duration(milliseconds: 420),
          builder: (context, value, _) => Container(
            width: _w,
            height: 215,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1.5),
            ),
            child: CustomPaint(painter: _VentPainter(value ?? color)),
          ),
        ),
      );

  Widget _innerGlow(Color accent, Color accentAlt) => _face(
        matrix: _z(10),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            width: 230,
            height: 290,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.55),
                  accentAlt.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
        ),
      );

  Widget _leg(Color color, Matrix4 matrix, double width) => _face(
        matrix: matrix,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          width: width,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(3),
              bottom: Radius.circular(5),
            ),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 20),
            ],
          ),
        ),
      );

  Widget _badge(Color color) => _face(
        matrix: Matrix4.translationValues(0, 138, _halfDepth + 1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 420),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 22),
            ],
          ),
          child: const Text(
            'MODCASE',
            style: TextStyle(
              color: Color(0xFF08090C),
              fontSize: 8.5,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
      );

  Widget _floorGlow(Color accent) => _face(
        matrix: Matrix4.translationValues(0, 196, 0)
            .multiplied(Matrix4.rotationX(math.pi / 2)),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [accent.withValues(alpha: 0.5), Colors.transparent],
                stops: const [0, 0.62],
              ),
            ),
          ),
        ),
      );
}

/// Перфорация фронтальной панели.
class _MeshPainter extends CustomPainter {
  const _MeshPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.clipRRect(rrect);
    canvas.drawRect(rect, Paint()..color = color);

    final hole = Paint()..color = const Color(0xFF04060B).withValues(alpha: 0.75);
    const step = 14.0;
    for (var y = step / 2; y < size.height; y += step) {
      for (var x = step / 2; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 2.9, hole);
      }
    }
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) => oldDelegate.color != color;
}

/// Вентиляционные прорези верхней крышки.
class _VentPainter extends CustomPainter {
  const _VentPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
    );
    canvas.drawRect(rect, Paint()..color = color);

    final slot = Paint()
      ..color = Color.lerp(color, const Color(0xFF000000), 0.45)!;
    for (var x = 0.0; x < size.width; x += 13) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 5, size.height), slot);
    }
  }

  @override
  bool shouldRepaint(_VentPainter oldDelegate) => oldDelegate.color != color;
}
