import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/config_controller.dart';
import '../theme/mod_colors.dart';
import 'format.dart';
import 'widgets/case_preview.dart';
import 'widgets/configurator_panel.dart';
import 'widgets/gradient_text.dart';
import 'widgets/mod_button.dart';
import 'widgets/pointer_field.dart';
import 'widgets/preset_rail.dart';
import 'widgets/sections.dart';

const double _maxWidth = 1280;
const double _wideBreakpoint = 1040;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sections = <String, GlobalKey>{
    'Пресеты': GlobalKey(),
    'Конструктор': GlobalKey(),
    'Материалы': GlobalKey(),
    'Каталог': GlobalKey(),
  };

  void _scrollTo(String section) {
    final target = _sections[section]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NavBar(sections: _sections.keys.toList(), onTap: _scrollTo),
        const _StatusStrip(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Hero(
                  onBuild: () => _scrollTo('Конструктор'),
                  onPresets: () => _scrollTo('Пресеты'),
                ),
                _PresetsSection(key: _sections['Пресеты']),
                _BuilderSection(key: _sections['Конструктор']),
                _MaterialsSection(key: _sections['Материалы']),
                _ShopSection(key: _sections['Каталог']),
                const _ProcessSection(),
                _FinalSection(onBuild: () => _scrollTo('Конструктор')),
                const _Footer(),
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
          padding:
              (padding ?? EdgeInsets.zero) +
              EdgeInsets.symmetric(horizontal: gutter),
          child: child,
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.sections, required this.onTap});

  final List<String> sections;
  final ValueChanged<String> onTap;

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
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.6),
                    blurRadius: 14,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text('MODCASE', style: text.titleLarge?.copyWith(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              'HYPER',
              style: text.labelSmall?.copyWith(color: c.accent, fontSize: 10),
            ),
            const Spacer(),
            if (wide) ...[
              for (final label in sections)
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: HotZone(
                    child: GestureDetector(
                      onTap: () => onTap(label),
                      child: Text(
                        label,
                        style: text.bodyMedium?.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ),
            ],
            ModButton(
              label: 'Собрать корпус',
              compact: true,
              onPressed: () => onTap('Конструктор'),
            ),
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
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
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.onBuild, required this.onPresets});

  final VoidCallback onBuild;
  final VoidCallback onPresets;

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
          spacing: 22,
          runSpacing: 14,
          children: [
            ModButton(label: 'Открыть конструктор', onPressed: onBuild),
            ModButton(
              label: 'Смотреть пресеты',
              style: ModButtonStyle.ghost,
              onPressed: onPresets,
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
    ('Платы', 'ATX / ITX'),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
  const _PresetsSection({super.key});

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
            lead:
                'Шесть собранных комбинаций материала и цвета. Нажми — '
                'корпус и вся страница перекрасятся в схему.',
          ),
          PresetRail(),
        ],
      ),
    );
  }
}

class _BuilderSection extends ConsumerWidget {
  const _BuilderSection({super.key});

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
            lead:
                'Выбери деталь, задай материал и цвет — модель, масса, '
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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

class _MaterialsSection extends StatelessWidget {
  const _MaterialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Wrap(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHead(
            eyebrow: 'Материалы',
            title: 'Пять пластиков. Разные характеры',
            lead:
                'Материалы можно смешивать: сетку — из PLA-CF, окно — из ASA, '
                'ножки — из silk. Цена пересчитывается по граммам.',
          ),
          MaterialsGrid(),
        ],
      ),
    );
  }
}

class _ShopSection extends StatelessWidget {
  const _ShopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _Wrap(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHead(
            eyebrow: 'Каталог',
            title: 'Готовые киты',
            lead:
                'Если конфигурация не нужна — берите набор целиком или '
                'отдельным модулем.',
          ),
          KitGrid(),
        ],
      ),
    );
  }
}

class _ProcessSection extends StatelessWidget {
  const _ProcessSection();

  @override
  Widget build(BuildContext context) {
    return _Wrap(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHead(
            eyebrow: 'Как это работает',
            title: 'От клика до сборки',
          ),
          ProcessSteps(),
        ],
      ),
    );
  }
}

class _FinalSection extends StatelessWidget {
  const _FinalSection({required this.onBuild});

  final VoidCallback onBuild;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;
    final display = MediaQuery.sizeOf(context).width < 700
        ? text.displayMedium
        : text.displayLarge;

    return _Wrap(
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: Column(
        children: [
          const _Eyebrow('Готово к сборке'),
          const SizedBox(height: 20),
          Text('Печатаем', style: display, textAlign: TextAlign.center),
          GradientText('твой корпус', gradient: c.ramp, style: display),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              'Открывай конструктор, собирай схему и отправляй в печать. '
              'Пресет можно скачать и напечатать самому — файлы открытые.',
              style: text.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 34),
          Wrap(
            spacing: 22,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              ModButton(label: 'Собрать корпус', onPressed: onBuild),
              ModButton(
                label: 'Скачать пресет',
                style: ModButtonStyle.ghost,
                onPressed: onBuild,
              ),
            ],
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
              Text(
                'NUNITO · NUNITO SANS · JETBRAINS MONO',
                style: text.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
