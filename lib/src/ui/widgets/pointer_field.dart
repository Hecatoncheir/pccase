import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../theme/mod_colors.dart';

/// Позиция курсора в глобальных координатах — её слушают фон, свечение
/// и наклон корпуса.
class PointerScope extends InheritedWidget {
  const PointerScope({required this.pointer, required super.child, super.key});

  final ValueListenable<Offset> pointer;

  static ValueListenable<Offset> of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PointerScope>();
    assert(scope != null, 'PointerScope не найден выше по дереву');
    return scope!.pointer;
  }

  @override
  bool updateShouldNotify(PointerScope oldWidget) =>
      oldWidget.pointer != pointer;
}

/// Фон страницы: восходящий тепловой поток частиц, отталкивание от курсора
/// и пятно свечения под ним. Аналог канвы из концепта.
///
/// В продакшене эту сцену стоит заменить фрагментным шейдером
/// (`flutter_shaders`, юниформы `uTime` / `uMouse`) — рисунок тот же,
/// но кадр стоит дешевле.
class PointerField extends StatefulWidget {
  const PointerField({required this.child, super.key});

  final Widget child;

  @override
  State<PointerField> createState() => _PointerFieldState();
}

class _PointerFieldState extends State<PointerField>
    with SingleTickerProviderStateMixin {
  final _pointer = ValueNotifier<Offset>(Offset.zero);
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
    _field.step(dt.clamp(0.0, 3.0), _pointer.value);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _pointer.dispose();
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
      onHover: (event) => _pointer.value = event.position,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _field.resize(constraints.biggest, [c.cold, c.mid, c.hot, c.silk]);
          return Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: c.plate)),
              Positioned.fill(
                child: ValueListenableBuilder<Offset>(
                  valueListenable: _pointer,
                  builder: (context, position, _) => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(
                          (position.dx / constraints.maxWidth) * 2 - 1,
                          (position.dy / constraints.maxHeight) * 2 - 1,
                        ),
                        radius: 0.42,
                        colors: [
                          c.accent.withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _FieldPainter(_field, _pointer),
                    isComplex: true,
                  ),
                ),
              ),
              PointerScope(pointer: _pointer, child: widget.child),
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

class _Field extends ChangeNotifier {
  final _random = math.Random(7);
  final List<_Particle> particles = [];
  List<Color> colors = const [];
  Size size = Size.zero;

  void resize(Size value, List<Color> palette) {
    colors = palette;
    if (value == size || value.isEmpty) return;
    size = value;
    final count = (value.width * value.height / 13000).round().clamp(40, 150);
    particles
      ..clear()
      ..addAll(List.generate(count, (i) {
        final p = _Particle(
          Offset(_random.nextDouble() * value.width,
              _random.nextDouble() * value.height),
          _random.nextDouble() * 0.32 + 0.07,
          _random.nextDouble() * 1.9 + 0.5,
          _random.nextDouble() * 0.5 + 0.2,
          _random.nextDouble() * math.pi * 2,
        );
        return p..colorIndex = i % 4;
      }));
  }

  void step(double dt, Offset pointer) {
    if (particles.isEmpty) return;
    for (final p in particles) {
      var next = p.position.translate(
        math.sin(p.phase) * 0.22 * dt,
        -p.speed * dt,
      );
      p.phase += 0.012 * dt;
      if (next.dy < -12) {
        next = Offset(_random.nextDouble() * size.width, size.height + 12);
      }
      p.position = next;

      final delta = p.position - pointer;
      final distanceSq = delta.distanceSquared;
      if (distanceSq < 22000 && distanceSq > 0.01) {
        final force = (1 - distanceSq / 22000) * 2.4;
        p.push += delta / delta.distance * force;
      }
      p.push *= 0.9;
    }
    notifyListeners();
  }
}

class _FieldPainter extends CustomPainter {
  _FieldPainter(this.field, this.pointer)
      : super(repaint: Listenable.merge([field, pointer]));

  final _Field field;
  final ValueListenable<Offset> pointer;

  @override
  void paint(Canvas canvas, Size size) {
    if (field.colors.isEmpty) return;
    final dot = Paint()..blendMode = BlendMode.plus;
    final link = Paint()
      ..blendMode = BlendMode.plus
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (final p in field.particles) {
      final at = p.position + p.push;
      final color = field.colors[p.colorIndex % field.colors.length];
      canvas.drawCircle(
        at,
        p.radius,
        dot..color = color.withValues(alpha: p.alpha * 0.55),
      );

      // связи только вокруг указателя — «магнитное поле» сопла
      final distance = (at - pointer.value).distance;
      if (distance < 160) {
        canvas.drawLine(
          at,
          pointer.value,
          link..color = color.withValues(alpha: (1 - distance / 160) * 0.3),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FieldPainter oldDelegate) => false;
}
