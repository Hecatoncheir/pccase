import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/case_part.dart';
import '../../state/config_controller.dart';
import '../../theme/mod_colors.dart';
import 'pointer_field.dart';

/// Корпус в 3D. Вершины коробки поворачиваются и проецируются вручную,
/// грани рисуются от дальней к ближней — вложенные [Transform] здесь не
/// годятся: у Flutter нет `preserve-3d`, каждая грань улетала бы в свой слой
/// и стыки расходились.
///
/// Под продакшен эту сцену заменит Spline или GLB; контракт останется тем же:
/// цвета деталей внутрь, наклон снаружи.
class CasePreview extends ConsumerWidget {
  const CasePreview({this.height = 520, super.key});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final c = context.mod;

    return SizedBox(
      height: height,
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

          return TweenAnimationBuilder<Offset>(
            tween: Tween<Offset>(
              end: Offset(
                (-12 - ny * 13) * math.pi / 180,
                (-28 + nx * 26) * math.pi / 180,
              ),
            ),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            builder: (context, rotation, _) => CustomPaint(
              size: Size.infinite,
              painter: _CasePainter(
                rx: rotation.dx,
                ry: rotation.dy,
                colors: {
                  for (final part in kParts) part.id: config.colorOf(part.id),
                },
                accent: c.accent,
                accentAlt: c.accentAlt,
                shell: c.plateDeep,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Точка после поворота: экранная позиция, глубина и масштаб перспективы.
typedef _P = ({Offset at, double z, double scale});

class _CasePainter extends CustomPainter {
  _CasePainter({
    required this.rx,
    required this.ry,
    required this.colors,
    required this.accent,
    required this.accentAlt,
    required this.shell,
  });

  final double rx;
  final double ry;
  final Map<PartId, Color> colors;
  final Color accent;
  final Color accentAlt;
  final Color shell;

  /// Полугабариты корпуса: ширина 210, высота 330, глубина 215.
  static const double w = 105;
  static const double h = 165;
  static const double d = 107.5;
  static const double focal = 1500;
  static const double floorY = 196;

  late Offset _origin;
  late double _fit;

  _P _project(double x, double y, double z) {
    final cx = math.cos(rx), sx = math.sin(rx);
    final cy = math.cos(ry), sy = math.sin(ry);

    final x1 = x * cy + z * sy;
    final z1 = -x * sy + z * cy;
    final y2 = y * cx - z1 * sx;
    final z2 = y * sx + z1 * cx;

    final s = focal / (focal - z2) * _fit;
    return (at: Offset(x1 * s, y2 * s) + _origin, z: z2, scale: s);
  }

  Path _quad(List<_P> points) {
    final path = Path()..moveTo(points.first.at.dx, points.first.at.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.at.dx, p.at.dy);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _fit = math.min(size.width / 460, size.height / 560).clamp(0.35, 1.15);
    _origin = Offset(size.width / 2, size.height / 2 - 20 * _fit);

    _paintPlate(canvas);
    _paintFloorGlow(canvas);

    // Грани коробки: дальние рисуем первыми, ближние — поверх.
    final faces = <(String, List<_P>)>[
      ('back', [
        _project(-w, -h, -d), _project(w, -h, -d),
        _project(w, h, -d), _project(-w, h, -d),
      ]),
      ('left', [
        _project(-w, -h, -d), _project(-w, -h, d),
        _project(-w, h, d), _project(-w, h, -d),
      ]),
      ('bottom', [
        _project(-w, h, -d), _project(w, h, -d),
        _project(w, h, d), _project(-w, h, d),
      ]),
      ('top', [
        _project(-w, -h, -d), _project(w, -h, -d),
        _project(w, -h, d), _project(-w, -h, d),
      ]),
      ('right', [
        _project(w, -h, d), _project(w, -h, -d),
        _project(w, h, -d), _project(w, h, d),
      ]),
      ('front', [
        _project(-w, -h, d), _project(w, -h, d),
        _project(w, h, d), _project(-w, h, d),
      ]),
    ]..sort((a, b) {
        final za = a.$2.fold(0.0, (sum, p) => sum + p.z) / a.$2.length;
        final zb = b.$2.fold(0.0, (sum, p) => sum + p.z) / b.$2.length;
        return za.compareTo(zb);
      });

    var innerDone = false;
    for (final (name, points) in faces) {
      // Внутренности — между дальними и ближними гранями,
      // чтобы их было видно сквозь стекло и перфорацию.
      if (!innerDone && (name == 'front' || name == 'right')) {
        _paintInnards(canvas);
        innerDone = true;
      }
      switch (name) {
        case 'front':
          _paintFront(canvas, points);
        case 'right':
          _paintGlass(canvas, points);
        case 'top':
          _paintTop(canvas, points);
        default:
          canvas.drawPath(
            _quad(points),
            Paint()..color = name == 'left' ? const Color(0xFF141821) : shell,
          );
          canvas.drawPath(
            _quad(points),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1
              ..color = Colors.white.withValues(alpha: 0.06),
          );
      }
    }

    _paintLegs(canvas);
  }

  /// Стол принтера: сетка в перспективе, окрашенная акцентом схемы.
  void _paintPlate(Canvas canvas) {
    const half = 320.0;
    const step = 40.0;
    for (var i = -half; i <= half; i += step) {
      final fade = 1 - (i.abs() / half);
      final paint = Paint()
        ..strokeWidth = 1
        ..color = accent.withValues(alpha: 0.05 + 0.16 * fade * fade);
      final a = _project(i, floorY, -half);
      final b = _project(i, floorY, half);
      canvas.drawLine(a.at, b.at, paint);
      final c = _project(-half, floorY, i);
      final e = _project(half, floorY, i);
      canvas.drawLine(c.at, e.at, paint);
    }
  }

  void _paintFloorGlow(Canvas canvas) {
    final center = _project(0, floorY, 0);
    final radius = 230 * center.scale;
    canvas.drawCircle(
      center.at,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: 0.5), Colors.transparent],
          stops: const [0, 0.75],
        ).createShader(Rect.fromCircle(center: center.at, radius: radius))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26),
    );
  }

  /// Материнская плата и видеокарта — видны сквозь стекло.
  void _paintInnards(Canvas canvas) {
    final mobo = _quad([
      _project(-w + 16, -h + 40, -d + 30),
      _project(-w + 16, -h + 40, d - 30),
      _project(-w + 16, h - 60, d - 30),
      _project(-w + 16, h - 60, -d + 30),
    ]);
    canvas.drawPath(mobo, Paint()..color = const Color(0xFF10261F));

    final gpu = _quad([
      _project(-w + 34, -h + 150, -d + 34),
      _project(-w + 34, -h + 150, d - 40),
      _project(-w + 34, -h + 192, d - 40),
      _project(-w + 34, -h + 192, -d + 34),
    ]);
    canvas.drawPath(gpu, Paint()..color = const Color(0xFF161C2B));
    canvas.drawPath(
      gpu,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = accentAlt.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Подсветка внутри корпуса.
    final glow = _project(0, 0, 0);
    canvas.drawCircle(
      glow.at,
      150 * glow.scale,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            accent.withValues(alpha: 0.45),
            accentAlt.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0, 0.45, 1],
        ).createShader(
          Rect.fromCircle(center: glow.at, radius: 150 * glow.scale),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
  }

  /// Фронтальная панель: заливка, свечение изнутри и перфорация.
  void _paintFront(Canvas canvas, List<_P> points) {
    final color = colors[PartId.front]!;
    final path = _quad(points);
    canvas.drawPath(path, Paint()..color = color);

    canvas.save();
    canvas.clipPath(path);
    final glow = _project(0, 40, d);
    canvas.drawCircle(
      glow.at,
      130 * glow.scale,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: 0.22), Colors.transparent],
          stops: const [0, 1],
        ).createShader(
          Rect.fromCircle(center: glow.at, radius: 130 * glow.scale),
        ),
    );

    final hole = Paint()..color = const Color(0xFF04060B).withValues(alpha: 0.7);
    for (var v = -h + 12; v < h - 10; v += 14) {
      for (var u = -w + 12; u < w - 10; u += 14) {
        final p = _project(u, v, d);
        canvas.drawCircle(p.at, 2.7 * p.scale, hole);
      }
    }
    canvas.restore();

    // Шильд.
    final badge = _quad([
      _project(-34, h - 44, d + 1),
      _project(34, h - 44, d + 1),
      _project(34, h - 26, d + 1),
      _project(-34, h - 26, d + 1),
    ]);
    final badgeColor = colors[PartId.badge]!;
    canvas.drawPath(
      badge,
      Paint()
        ..color = badgeColor.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(badge, Paint()..color = badgeColor);

    _stroke(canvas, path, Colors.white.withValues(alpha: 0.14), 1.5);
  }

  /// Боковое окно: тонированное стекло с толстой рамкой.
  void _paintGlass(Canvas canvas, List<_P> points) {
    final tint = colors[PartId.side]!;
    final path = _quad(points);
    final bounds = path.getBounds();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.34),
            tint.withValues(alpha: 0.08),
            tint.withValues(alpha: 0.22),
          ],
        ).createShader(bounds),
    );
    _stroke(canvas, path, tint.withValues(alpha: 0.75), 7);
    _stroke(canvas, path, Colors.white.withValues(alpha: 0.12), 1.5);
  }

  /// Верхняя крышка с вентиляционными прорезями.
  void _paintTop(Canvas canvas, List<_P> points) {
    final color = colors[PartId.top]!;
    final path = _quad(points);
    canvas.drawPath(path, Paint()..color = color);

    canvas.save();
    canvas.clipPath(path);
    final slot = Paint()
      ..color = Color.lerp(color, const Color(0xFF000000), 0.5)!;
    for (var u = -w + 6; u < w - 6; u += 13) {
      canvas.drawPath(
        _quad([
          _project(u, -h, -d + 16),
          _project(u + 5, -h, -d + 16),
          _project(u + 5, -h, d - 16),
          _project(u, -h, d - 16),
        ]),
        slot,
      );
    }
    canvas.restore();
    _stroke(canvas, path, Colors.white.withValues(alpha: 0.16), 1.5);
  }

  /// Ножки под передней и боковой гранями.
  void _paintLegs(Canvas canvas) {
    final color = colors[PartId.feet]!;
    final paint = Paint()..color = color;
    final glow = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final front = _quad([
      _project(-w + 12, h + 2, d),
      _project(w - 12, h + 2, d),
      _project(w - 12, h + 17, d),
      _project(-w + 12, h + 17, d),
    ]);
    final side = _quad([
      _project(w, h + 2, d - 12),
      _project(w, h + 2, -d + 12),
      _project(w, h + 17, -d + 12),
      _project(w, h + 17, d - 12),
    ]);

    for (final path in [side, front]) {
      canvas.drawPath(path, glow);
      canvas.drawPath(path, paint);
    }
  }

  void _stroke(Canvas canvas, Path path, Color color, double width) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_CasePainter old) =>
      old.rx != rx ||
      old.ry != ry ||
      old.accent != accent ||
      old.accentAlt != accentAlt ||
      !mapEquals(old.colors, colors);
}
