import 'package:flutter/material.dart';

import '../../domain/kit.dart';
import '../../theme/mod_colors.dart';
import '../format.dart';
import 'mod_button.dart';
import 'mod_card.dart';
import 'tilt_card.dart';

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
