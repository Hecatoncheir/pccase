import 'package:flutter/material.dart';

import '../../domain/kit.dart';
import '../../theme/mod_colors.dart';

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
