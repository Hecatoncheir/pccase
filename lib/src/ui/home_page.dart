import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/config_controller.dart';
import '../theme/mod_colors.dart';
import 'format.dart';
import 'widgets/case_preview.dart';
import 'widgets/configurator_panel.dart';
import 'widgets/gradient_text.dart';
import 'widgets/mod_button.dart';
import 'widgets/preset_rail.dart';

const double _maxWidth = 1280;
const double _wideBreakpoint = 1040;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = PrimaryScrollController.maybeOf(context);
    return Column(
      children: [
        const _NavBar(),
        const _StatusStrip(),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            child: const Column(
              children: [
                _Hero(),
                _PresetsSection(),
                _BuilderSection(),
                _Footer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ограничитель ширины контента — тот же 1280 px, что в концепте.
class _Wrap extends StatelessWidget {
  const _Wrap({required this.child, this.padding});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width < 600 ? 18.0 : 52.0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: (padding ?? EdgeInsets.zero) +
              EdgeInsets.symmetric(horizontal: gutter),
          child: child,
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.plate.withValues(alpha: 0.72),
        border: Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: _Wrap(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                gradient: c.ramp,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                  bottom: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(color: c.accent.withValues(alpha: 0.6), blurRadius: 14),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('MODCASE', style: text.titleLarge?.copyWith(fontSize: 16)),
            const SizedBox(width: 6),
            Text('HYPER',
                style: text.labelSmall?.copyWith(color: c.accent, fontSize: 10)),
            const Spacer(),
            if (wide) ...[
              for (final label in const [
                'Пресеты',
                'Конструктор',
                'Материалы',
                'Каталог',
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Text(
                    label,
                    style: text.bodyMedium?.copyWith(fontSize: 14),
                  ),
                ),
            ],
            ModButton(label: 'Собрать корпус', compact: true, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip();

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= 620;

    Widget cell(String label, String value) => Padding(
          padding: const EdgeInsets.only(right: 26),
          child: RichText(
            text: TextSpan(
              style: text.labelSmall,
              children: [
                TextSpan(text: '${label.toUpperCase()} '),
                TextSpan(
                  text: value.toUpperCase(),
                  style: text.labelSmall?.copyWith(color: c.inkSoft),
                ),
              ],
            ),
          ),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.panel.withValues(alpha: 0.55),
        border: Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: _Wrap(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color: c.silk,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: c.silk, blurRadius: 8)],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 26),
              child: Text(
                'ФЕРМА ПЕЧАТАЕТ',
                style: text.labelSmall?.copyWith(color: c.silk),
              ),
            ),
            cell('сопло', '245°C'),
            cell('стол', '70°C'),
            if (wide) ...[
              cell('слой', '0.20 мм'),
              cell('заполнение', '25% gyroid'),
              cell('отгрузка', '3–5 дней'),
            ],
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= _wideBreakpoint;
    final display = width < 700 ? text.displayMedium : text.displayLarge;

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow('ModCase Hyper · Universal PC Case · FDM'),
        const SizedBox(height: 20),
        Text('Корпус, который', style: display),
        GradientText('печатают', gradient: c.ramp, style: display),
        Text('под тебя', style: display),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Выбираешь конфигурацию, материал и цвет каждой панели — ферма '
            'печатает набор под твой билд и присылает готовым к сборке. '
            'Или забираешь пресет и печатаешь сам.',
            style: text.bodyLarge,
          ),
        ),
        const SizedBox(height: 34),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            ModButton(label: 'Открыть конструктор', onPressed: () {}),
            ModButton(
              label: 'Смотреть пресеты',
              style: ModButtonStyle.ghost,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 44),
        const _SpecStrip(),
      ],
    );

    return _Wrap(
      padding: const EdgeInsets.only(top: 56, bottom: 64),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: copy),
                const SizedBox(width: 40),
                const Expanded(child: CasePreview()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [copy, const SizedBox(height: 32), const CasePreview()],
            ),
    );
  }
}

class _SpecStrip extends StatelessWidget {
  const _SpecStrip();

  static const _specs = <(String, String)>[
    ('Деталей', '6'),
    ('Цветов', '24'),
    ('Материалов', '5'),
    ('Платы', 'ATX→ITX'),
    ('Видеокарта', '360 мм'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.lineSoft),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final (index, spec) in _specs.indexed)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    left: index == 0
                        ? BorderSide.none
                        : BorderSide(color: c.lineSoft),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spec.$1.toUpperCase(), style: text.labelSmall),
                    const SizedBox(height: 5),
                    Text(
                      spec.$2,
                      style: text.titleLarge?.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 1,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: c.accent,
            boxShadow: [BoxShadow(color: c.accent, blurRadius: 10)],
          ),
        ),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}

class _SectionHead extends StatelessWidget {
  const _SectionHead({required this.eyebrow, required this.title, this.lead});

  final String eyebrow;
  final String title;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final heading = Text(title, style: text.headlineLarge);
    final leadText = lead == null
        ? const SizedBox.shrink()
        : ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(lead!, style: text.bodyLarge),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(eyebrow),
        const SizedBox(height: 16),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: heading),
              const SizedBox(width: 28),
              Expanded(child: leadText),
            ],
          )
        else ...[
          heading,
          const SizedBox(height: 16),
          leadText,
        ],
        const SizedBox(height: 48),
      ],
    );
  }
}

class _PresetsSection extends StatelessWidget {
  const _PresetsSection();

  @override
  Widget build(BuildContext context) {
    return _Wrap(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHead(
            eyebrow: 'Пресеты',
            title: 'Готовые схемы покраски',
            lead: 'Шесть собранных комбинаций материала и цвета. Нажми — '
                'корпус и вся страница перекрасятся в схему.',
          ),
          PresetRail(),
        ],
      ),
    );
  }
}

class _BuilderSection extends ConsumerWidget {
  const _BuilderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = ref.watch(quoteProvider);
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    final preview = Column(
      children: [
        const CasePreview(height: 460),
        const SizedBox(height: 16),
        _Totals(
          cells: [
            ('Масса пластика', grams(quote.grams)),
            ('Время печати', hoursMinutes(quote.hours)),
            ('Пластик', rub(quote.plastic)),
          ],
        ),
      ],
    );

    return _Wrap(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHead(
            eyebrow: 'Конструктор',
            title: 'Шесть деталей — твои правила',
            lead: 'Выбери деталь, задай материал и цвет — модель, масса, '
                'время печати и цена пересчитываются мгновенно.',
          ),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: preview),
                const SizedBox(width: 40),
                const SizedBox(width: 500, child: ConfiguratorPanel()),
              ],
            )
          else ...[
            preview,
            const SizedBox(height: 24),
            const ConfiguratorPanel(),
          ],
        ],
      ),
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.cells});

  final List<(String, String)> cells;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.lineSoft),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final (index, cell) in cells.indexed)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    left: index == 0
                        ? BorderSide.none
                        : BorderSide(color: c.lineSoft),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cell.$1.toUpperCase(), style: text.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      cell.$2,
                      style: text.titleLarge?.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;
    return _Wrap(
      padding: const EdgeInsets.only(top: 34, bottom: 46),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.lineSoft)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              Text('MODCASE HYPER · КАРКАС ПРИЛОЖЕНИЯ', style: text.labelSmall),
              Text('UNBOUNDED · MANROPE · JETBRAINS MONO', style: text.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
