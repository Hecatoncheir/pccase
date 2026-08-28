import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/mod_colors.dart';

/// Состояние указателя на всю страницу: позиция курсора и признак того,
/// что он над интерактивным элементом. Слушают фон, курсор-сопло,
/// магнитные кнопки и наклон корпуса.
class PointerScope extends InheritedWidget {
  const PointerScope({
    required this.pointer,
    required this.hot,
    required super.child,
    super.key,
  });

  final ValueListenable<Offset> pointer;
  final ValueNotifier<bool> hot;

  static PointerScope _of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PointerScope>();
    assert(scope != null, 'PointerScope не найден выше по дереву');
    return scope!;
  }

  static ValueListenable<Offset> of(BuildContext context) =>
      _of(context).pointer;

  static ValueNotifier<bool> hotOf(BuildContext context) => _of(context).hot;

  @override
  bool updateShouldNotify(PointerScope oldWidget) =>
      oldWidget.pointer != pointer || oldWidget.hot != hot;
}

/// Курсор превращается в сопло: кольцо тянется с запаздыванием, горячее
/// ядро идёт быстрее, а за движением остаётся экструзионный след, который
/// остывает из расплава в цвет активной схемы. Над кнопками кольцо
/// раскрывается и зеленеет.
class HotZone extends StatelessWidget {
  const HotZone({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final hot = PointerScope.hotOf(context);
    return MouseRegion(
      onEnter: (_) => hot.value = true,
      onExit: (_) => hot.value = false,
      child: child,
    );
  }
}

/// Фон страницы: восходящий тепловой поток частиц, отталкивание от курсора,
/// пятно свечения под ним и сам курсор-сопло.
///
/// В продакшене сцену стоит перенести во фрагментный шейдер
/// (`flutter_shaders`, юниформы `uTime` / `uMouse`) — рисунок тот же,
/// но кадр дешевле.
class PointerField extends StatefulWidget {
  const PointerField({required this.child, super.key});

  final Widget child;

  @override
  State<PointerField> createState() => _PointerFieldState();
}

class _PointerFieldState extends State<PointerField>
    with SingleTickerProviderStateMixin {
  final _pointer = ValueNotifier<Offset>(Offset.zero);
  final _hot = ValueNotifier<bool>(false);
  final _field = _Field();
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 16666.0;
    _last = elapsed;
    _field.step(dt.clamp(0.0, 3.0), _pointer.value, _hot.value);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _pointer.dispose();
    _hot.dispose();
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && _ticker.isActive) _ticker.stop();

    return MouseRegion(
      opaque: false,
      cursor: reduceMotion ? MouseCursor.defer : SystemMouseCursors.none,
      onHover: (event) => _pointer.value = event.position,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _field.resize(
            constraints.biggest,
            [c.cold, c.mid, c.hot, c.silk],
            accent: c.accent,
            silk: c.silk,
            molten: c.molten,
            blend: c.glowBlend,
            glow: c.glowStrength,
          );
          return Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: c.plate)),
              // Свечение и частицы — под контентом, след и сопло — над ним.
              // Оба слоя за RepaintBoundary, иначе каждый кадр пачкает
              // всё дерево страницы.
              Positioned.fill(
                child: RepaintBoundary(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _FieldPainter(_field, _Layer.behind),
                      isComplex: true,
                    ),
                  ),
                ),
              ),
              PointerScope(pointer: _pointer, hot: _hot, child: widget.child),
              Positioned.fill(
                child: RepaintBoundary(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _FieldPainter(_field, _Layer.above),
                      isComplex: true,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Particle {
  _Particle(this.position, this.speed, this.radius, this.alpha, this.phase);

  Offset position;
  Offset push = Offset.zero;
  double speed;
  double radius;
  double alpha;
  double phase;
  int colorIndex = 0;
}

/// Капля расплава из сопла: живёт около секунды и остывает.
class _Spark {
  _Spark(this.position, this.velocity, this.radius);

  Offset position;
  Offset velocity;
  double radius;
  double life = 1;
}

class _Field extends ChangeNotifier {
  final _random = math.Random(7);
  final List<_Particle> particles = [];
  final List<_Spark> sparks = [];

  List<Color> colors = const [];
  Color accent = const Color(0xFFFF4A1C);
  Color silk = const Color(0xFF16F2AE);
  Color molten = const Color(0xFFFFD9A8);
  BlendMode blend = BlendMode.plus;
  double glow = 0.16;
  Size size = Size.zero;

  Offset pointer = Offset.zero;
  Offset ring = Offset.zero;
  Offset core = Offset.zero;
  double spin = 0;
  bool hot = false;
  bool awake = false;

  void resize(
    Size value,
    List<Color> palette, {
    required Color accent,
    required Color silk,
    required Color molten,
    required BlendMode blend,
    required double glow,
  }) {
    colors = palette;
    this.accent = accent;
    this.silk = silk;
    this.molten = molten;
    this.blend = blend;
    this.glow = glow;
    if (value == size || value.isEmpty) return;
    size = value;
    final count = (value.width * value.height / 13000).round().clamp(40, 150);
    particles
      ..clear()
      ..addAll(
        List.generate(count, (i) {
          return _Particle(
            Offset(
              _random.nextDouble() * value.width,
              _random.nextDouble() * value.height,
            ),
            _random.nextDouble() * 0.32 + 0.07,
            _random.nextDouble() * 1.9 + 0.5,
            _random.nextDouble() * 0.5 + 0.2,
            _random.nextDouble() * math.pi * 2,
          )..colorIndex = i % 4;
        }),
      );
  }

  void step(double dt, Offset next, bool isHot) {
    if (particles.isEmpty) return;
    hot = isHot;
    spin += 0.02 * dt;

    final moved = next - pointer;
    if (next != Offset.zero) {
      if (!awake) {
        awake = true;
        ring = next;
        core = next;
      }
      if (moved.distance > 0.6) _emit(next, moved);
      pointer = next;
    }

    // Кольцо отстаёт, ядро догоняет быстрее — как в концепте.
    ring += (pointer - ring) * (0.18 * dt).clamp(0.0, 1.0);
    core += (pointer - core) * (0.45 * dt).clamp(0.0, 1.0);

    for (final p in particles) {
      var position = p.position.translate(
        math.sin(p.phase) * 0.22 * dt,
        -p.speed * dt,
      );
      p.phase += 0.012 * dt;
      if (position.dy < -12) {
        position = Offset(_random.nextDouble() * size.width, size.height + 12);
      }
      p.position = position;

      final delta = p.position - pointer;
      final distanceSq = delta.distanceSquared;
      if (distanceSq < 22000 && distanceSq > 0.01) {
        final force = (1 - distanceSq / 22000) * 2.4;
        p.push += delta / delta.distance * force;
      }
      p.push *= 0.9;
    }

    for (var i = sparks.length - 1; i >= 0; i--) {
      final spark = sparks[i];
      spark.position += spark.velocity * dt;
      spark.velocity = spark.velocity.translate(0, 0.012 * dt);
      spark.life -= 0.022 * dt;
      if (spark.life <= 0) sparks.removeAt(i);
    }

    notifyListeners();
  }

  void _emit(Offset at, Offset moved) {
    final speed = math.min(moved.distance, 40.0);
    final count = speed > 6 ? 2 : 1;
    for (var i = 0; i < count; i++) {
      sparks.add(
        _Spark(
          at.translate(
            (_random.nextDouble() - .5) * 6,
            (_random.nextDouble() - .5) * 6,
          ),
          Offset(
            -moved.dx * 0.035 + (_random.nextDouble() - .5) * .5,
            -moved.dy * 0.035 + (_random.nextDouble() - .5) * .5 - .25,
          ),
          _random.nextDouble() * 2.4 + 1.2,
        ),
      );
    }
    if (sparks.length > 220) sparks.removeRange(0, sparks.length - 220);
  }
}

/// Что рисуем: фон под контентом или курсор поверх него.
enum _Layer { behind, above }

class _FieldPainter extends CustomPainter {
  _FieldPainter(this.field, this.layer) : super(repaint: field);

  final _Field field;
  final _Layer layer;

  @override
  void paint(Canvas canvas, Size size) {
    if (field.colors.isEmpty) return;
    if (layer == _Layer.above) {
      _paintTrail(canvas);
      if (field.awake) _paintNozzle(canvas);
      return;
    }
    _paintGlow(canvas, size);
    _paintParticles(canvas);
  }

  /// Пятно под курсором. Раньше это был полноэкранный DecoratedBox,
  /// который пересобирался на каждое движение мыши.
  void _paintGlow(Canvas canvas, Size size) {
    if (!field.awake) return;
    final radius = math.min(size.width, size.height) * 0.42;
    canvas.drawCircle(
      field.pointer,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            field.accent.withValues(alpha: field.glow),
            Colors.transparent,
          ],
          stops: const [0, 0.68],
        ).createShader(Rect.fromCircle(center: field.pointer, radius: radius)),
    );
  }

  void _paintParticles(Canvas canvas) {
    // На светлом грунте свет не складывается — рисуем обычным наложением
    // и плотнее, иначе частицы просто исчезают.
    final additive = field.blend == BlendMode.plus;
    final density = additive ? 0.55 : 0.75;
    final dot = Paint()..blendMode = field.blend;
    final link = Paint()
      ..blendMode = field.blend
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (final p in field.particles) {
      final at = p.position + p.push;
      final color = field.colors[p.colorIndex % field.colors.length];
      canvas.drawCircle(
        at,
        p.radius,
        dot..color = color.withValues(alpha: p.alpha * density),
      );

      // Связи только вокруг указателя — «магнитное поле» сопла.
      final distance = (at - field.pointer).distance;
      if (field.awake && distance < 160) {
        canvas.drawLine(
          at,
          field.pointer,
          link
            ..color = color.withValues(
              alpha: (1 - distance / 160) * (additive ? 0.3 : 0.22),
            ),
        );
      }
    }
  }

  /// Экструзионный след: из расплава в акцент схемы.
  void _paintTrail(Canvas canvas) {
    final dot = Paint()..blendMode = field.blend;
    for (final spark in field.sparks) {
      canvas.drawCircle(
        spark.position,
        spark.radius * spark.life,
        dot
          ..color = Color.lerp(
            field.molten,
            field.accent,
            1 - spark.life,
          )!.withValues(alpha: spark.life * 0.8),
      );
    }
  }

  /// Сопло: кольцо с пунктирной обоймой и горячее ядро.
  void _paintNozzle(Canvas canvas) {
    final additive = field.blend == BlendMode.plus;
    final radius = field.hot ? 29.0 : 17.0;
    final tint = field.hot ? field.silk : field.accent;

    canvas.drawCircle(
      field.ring,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..blendMode = field.blend
        ..color = additive ? Color.lerp(tint, Colors.white, 0.2)! : tint,
    );

    final dashes = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..blendMode = field.blend
      ..color = tint.withValues(alpha: additive ? 0.4 : 0.55);
    final ring = Rect.fromCircle(center: field.ring, radius: radius + 9);
    for (var i = 0; i < 12; i++) {
      final start = field.spin + i * math.pi / 6;
      canvas.drawArc(ring, start, 0.18, false, dashes);
    }

    canvas.drawCircle(
      field.core,
      3,
      Paint()
        ..blendMode = field.blend
        ..color = field.molten
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      field.core,
      2.5,
      Paint()
        ..blendMode = field.blend
        ..color = additive ? const Color(0xFFFFE9CF) : field.molten,
    );
  }

  @override
  bool shouldRepaint(_FieldPainter oldDelegate) => false;
}
