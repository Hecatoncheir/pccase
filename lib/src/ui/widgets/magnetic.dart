import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'pointer_field.dart';

/// Магнитная зона вокруг элемента: пока курсор в ней, ребёнок тянется
/// к указателю, а на выходе плавно возвращается на место.
///
/// Механика повторяет приём из вёрстки (GSAP `parallaxIt`): смещение
/// считается от центра невидимой области, которая шире элемента на
/// [padding]; слежение идёт кривой `power1.out` за 0.6 с, возврат —
/// `power3.out` за те же 0.6 с.
///
/// Зона не влияет на раскладку: указатель берётся из [PointerScope],
/// а смещение рисуется трансформацией, поэтому измеряется всегда
/// исходный прямоугольник, а не уехавший.
///
/// Притягивается только ближайший к курсору элемент — иначе соседние
/// кнопки съезжались бы в одну точку.
class Magnetic extends StatefulWidget {
  const Magnetic({
    required this.child,
    this.padding = 40,
    this.movement = 0.42,
    this.maxTravel,
    this.builder,
    super.key,
  });

  final Widget child;

  /// Насколько зона шире самого элемента, в логических пикселях.
  final double padding;

  /// Доля расстояния от центра до курсора, на которую уезжает элемент.
  /// `1.0` — центр элемента встаёт ровно под курсор, как в оригинале.
  final double movement;

  /// Потолок смещения. Широкая пилюля при `movement` под единицу уехала бы
  /// на полкнопки и налезла на соседнюю — поэтому ход ограничиваем.
  final double? maxTravel;

  /// Получает уже сглаженное смещение — так внутренний слой можно увести
  /// дальше корпуса и получить параллакс.
  final Widget Function(BuildContext context, Offset pull, Widget child)?
  builder;

  @override
  State<Magnetic> createState() => _MagneticState();
}

class _MagneticState extends State<Magnetic>
    with SingleTickerProviderStateMixin
    implements MagnetTarget {
  // Притяжение — сразу, как только курсор рядом: короткий доводчик вместо
  // полусекундного слежения. Возврат остаётся неспешным, power3.out.
  static const _followCurve = Curves.easeOutCubic;
  static const _returnCurve = Curves.easeOutQuart;
  static const _followDuration = Duration(milliseconds: 130);
  static const _returnDuration = Duration(milliseconds: 600);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _followDuration,
  );
  Animation<Offset> _pull = const AlwaysStoppedAnimation(Offset.zero);
  Offset _target = Offset.zero;

  ValueListenable<Offset>? _pointer;
  MagnetRegistry? _registry;
  bool _enabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _enabled = !MediaQuery.disableAnimationsOf(context);

    final registry = PointerScope.magnetsOf(context);
    if (!identical(registry, _registry)) {
      _registry?.remove(this);
      _registry = registry..add(this);
    }

    final pointer = PointerScope.of(context);
    if (!identical(pointer, _pointer)) {
      _pointer?.removeListener(_onPointer);
      _pointer = pointer..addListener(_onPointer);
    }
  }

  @override
  void dispose() {
    _pointer?.removeListener(_onPointer);
    _registry?.remove(this);
    _controller.dispose();
    super.dispose();
  }

  void _onPointer() {
    if (!_enabled) return;
    _registry?.update(_pointer!.value);
  }

  @override
  double get magnetPadding => widget.padding;

  /// Расстояние от курсора до прямоугольника элемента; внутри — ноль.
  @override
  double? distanceTo(Offset pointer) {
    final rect = _rect;
    if (rect == null) return null;
    final dx = math.max(
      math.max(rect.left - pointer.dx, 0.0),
      pointer.dx - rect.right,
    );
    final dy = math.max(
      math.max(rect.top - pointer.dy, 0.0),
      pointer.dy - rect.bottom,
    );
    return math.sqrt(dx * dx + dy * dy);
  }

  Rect? _rectCache;
  int _rectAt = 0;

  /// `localToGlobal` идёт по всей цепочке трансформаций вверх, а кнопок
  /// на странице восемь и указатель дёргается чаще кадра — хватает
  /// одного пересчёта на кадр.
  Rect? get _rect {
    final now = DateTime.now().microsecondsSinceEpoch;
    if (_rectCache != null && now - _rectAt < 16000) return _rectCache;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return null;
    _rectAt = now;
    return _rectCache = box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  void engage({required bool engaged, required Offset pointer}) {
    if (!_enabled) return;
    if (!engaged) {
      _animateTo(Offset.zero, _returnCurve, _returnDuration);
      return;
    }
    final rect = _rect;
    if (rect == null) return;

    var pull = (pointer - rect.center) * widget.movement;
    final limit = widget.maxTravel;
    if (limit != null && pull.distance > limit) {
      pull = pull / pull.distance * limit;
    }
    _animateTo(pull, _followCurve, _followDuration);
  }

  void _animateTo(Offset target, Curve curve, Duration duration) {
    if ((target - _target).distance < 0.5 && _controller.isAnimating) return;
    if (target == _target && !_controller.isAnimating) return;

    _target = target;
    _pull = Tween<Offset>(
      begin: _pull.value,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));
    _controller
      ..duration = duration
      ..forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;
    // Слушаем именно контроллер: _pull подменяется на каждом перенацеливании,
    // и подписка на него отвалилась бы после первой же смены.
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final pull = _pull.value;
        final body = child!;
        return widget.builder?.call(context, pull, body) ??
            Transform.translate(offset: pull, child: body);
      },
    );
  }
}
