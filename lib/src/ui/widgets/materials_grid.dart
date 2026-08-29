import 'package:flutter/material.dart';

import '../../domain/filament.dart';
import '../../theme/mod_colors.dart';
import 'mod_card.dart';
import 'tilt_card.dart';

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
            filament.title,
            style: text.headlineMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            '${filament.label} · ${filament.pricePerGram.toStringAsFixed(1)} ₽ за грамм'
                .toUpperCase(),
            style: text.labelSmall?.copyWith(color: c.accent),
          ),
          const SizedBox(height: 12),
          Text(filament.note, style: text.bodySmall),
          const SizedBox(height: 18),
          for (final meter in filament.meters) _Meter(meter: meter),
          const SizedBox(height: 4),
          // Для тех, кто скачает пресет и напечатает сам.
          Text(
            'печатается при ${filament.tempLabel}'.toUpperCase(),
            style: text.labelSmall,
          ),
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
