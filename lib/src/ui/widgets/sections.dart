import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../domain/filament.dart';
import '../../domain/kit.dart';
import '../../theme/mod_colors.dart';
import '../format.dart';
import 'mod_button.dart';
import 'pointer_field.dart';

/// Карточка на общем фоне панели — база для материалов и каталога.
class ModCard extends StatelessWidget {
  const ModCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.panel, c.panel.withValues(alpha: 0.4)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.lineSoft),
      ),
      child: child,
    );
  }
}

/// Пять пластиков с характеристиками — шкалы залиты температурной рампой.
class MaterialsGrid extends StatelessWidget {
  const MaterialsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        final columns = (constraints.maxWidth / 230).floor().clamp(1, 5);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final id in FilamentId.values)
              SizedBox(
                width: width,
                child: TiltCard(child: _MaterialCard(filamentOf(id))),
              ),
          ],
        );
      },
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard(this.filament);

  final Filament filament;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;

    return ModCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filament.label,
            style: text.headlineMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            'сопло ${filament.tempLabel} · ${filament.pricePerGram.toStringAsFixed(1)} ₽/г'
                .toUpperCase(),
            style: text.labelSmall?.copyWith(color: c.accent),
          ),
          const SizedBox(height: 12),
          Text(filament.note, style: text.bodySmall),
          const SizedBox(height: 18),
          for (final meter in filament.meters) _Meter(meter: meter),
        ],
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.meter});

  final FilamentMeter meter;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(meter.label.toUpperCase(), style: text.labelSmall),
              ),
              Text(
                '${meter.value}',
                style: text.labelSmall?.copyWith(color: c.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(height: 4, color: c.line),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: meter.value / 100),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FractionallySizedBox(
                    widthFactor: value,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(gradient: c.ramp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Готовые киты каталога.
class KitGrid extends StatelessWidget {
  const KitGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 18.0;
        final columns = (constraints.maxWidth / 265).floor().clamp(1, 4);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final kit in kKits)
              SizedBox(
                width: width,
                child: TiltCard(child: _KitCard(kit)),
              ),
          ],
        );
      },
    );
  }
}

class _KitCard extends StatelessWidget {
  const _KitCard(this.kit);

  final Kit kit;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;

    return ModCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
            child: Container(
              height: 172,
              decoration: BoxDecoration(
                color: c.panelRaised,
                gradient: RadialGradient(
                  center: Alignment.bottomCenter,
                  radius: 1.1,
                  colors: [kit.from.withValues(alpha: 0.5), Colors.transparent],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -0.12,
                    child: Container(
                      width: 88,
                      height: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [kit.from, kit.to],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: kit.from.withValues(alpha: 0.45),
                            blurRadius: 50,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: c.line),
                        color: c.plate.withValues(alpha: 0.6),
                      ),
                      child: Text(
                        kit.tag.toUpperCase(),
                        style: text.labelSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kit.name, style: text.titleLarge?.copyWith(fontSize: 17)),
                const SizedBox(height: 8),
                Text(kit.description, style: text.bodySmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        rub(kit.price),
                        style: text.labelLarge?.copyWith(fontSize: 17),
                      ),
                    ),
                    ModButton(
                      label: 'В корзину',
                      compact: true,
                      style: ModButtonStyle.ghost,
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: c.panelRaised,
                              content: Text(
                                '«${kit.name}» — ${rub(kit.price)} в корзине',
                                style: text.bodyMedium,
                              ),
                            ),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Путь заказа. Нумерация здесь не украшение — это реальная очерёдность.
class ProcessSteps extends StatelessWidget {
  const ProcessSteps({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 250).floor().clamp(1, 4);
        final width = constraints.maxWidth / columns;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: c.lineSoft),
            borderRadius: BorderRadius.circular(22),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Wrap(
              children: [
                for (final (index, step) in kSteps.indexed)
                  Container(
                    width: width,
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                    decoration: BoxDecoration(
                      color: c.plate,
                      border: Border(
                        left: index % columns == 0
                            ? BorderSide.none
                            : BorderSide(color: c.lineSoft),
                        top: index < columns
                            ? BorderSide.none
                            : BorderSide(color: c.lineSoft),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ШАГ ${(index + 1).toString().padLeft(2, '0')}',
                          style: text.labelSmall?.copyWith(color: c.accent),
                        ),
                        const SizedBox(height: 14),
                        Text(step.$1, style: text.titleLarge),
                        const SizedBox(height: 10),
                        Text(step.$2, style: text.bodySmall),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

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
