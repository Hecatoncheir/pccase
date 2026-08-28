import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/case_part.dart';
import '../../domain/configuration.dart';
import '../../domain/preset.dart';
import '../../state/config_controller.dart';
import '../../theme/mod_colors.dart';
import '../format.dart';
import 'sections.dart';

/// Готовые схемы покраски. Выбор пресета меняет и конфигурацию,
/// и акцент всей темы — переход анимирует `AnimatedTheme`.
class PresetRail extends ConsumerWidget {
  const PresetRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(presetProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 340).floor().clamp(1, 3);
        const gap = 16.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final preset in kPresets)
              SizedBox(
                width: width,
                child: _PresetCard(
                  preset: preset,
                  selected: preset.id == active.id,
                  onTap: () => ref.read(presetProvider.notifier).select(preset),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final Preset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;
    final quote = quoteFor(CaseConfiguration.fromPreset(preset));

    return TiltCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          mouseCursor: MouseCursor.defer,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c.panel, c.panel.withValues(alpha: 0.4)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: selected ? c.accent : c.lineSoft),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: c.accent.withValues(alpha: 0.28),
                        blurRadius: 60,
                        spreadRadius: -30,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(preset.name, style: text.titleLarge)),
                    if (selected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: c.accent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'АКТИВЕН',
                          style: text.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  '${preset.tag} · ${quote.grams} г'.toUpperCase(),
                  style: text.labelSmall,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    for (final part in const [
                      PartId.front,
                      PartId.side,
                      PartId.feet,
                      PartId.comb,
                    ])
                      Expanded(
                        child: Container(
                          height: 28,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: preset.colors[part],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(rub(quote.total), style: text.labelLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
