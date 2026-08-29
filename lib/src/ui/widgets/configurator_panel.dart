import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/case_part.dart';
import '../../domain/configuration.dart';
import '../../domain/filament.dart';
import '../../domain/filament_color.dart';
import '../../state/config_controller.dart';
import '../../theme/mod_colors.dart';
import '../format.dart';
import 'mod_button.dart';
import 'pointer_field.dart';

/// Правая колонка конструктора: деталь → материал → цвет → смета.
class ConfiguratorPanel extends ConsumerWidget {
  const ConfiguratorPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final selected = ref.watch(selectedPartProvider);
    final quote = ref.watch(quoteProvider);
    final filament = config.filamentOf(selected);
    final color = config.colorOf(selected);
    final c = context.mod;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Panel(
          title: 'Детали набора',
          trailing: '${config.materialCount} материала в наборе',
          child: Column(
            children: [
              for (final part in kParts)
                _PartRow(
                  part: part,
                  color: config.colorOf(part.id),
                  filament: config.filamentOf(part.id),
                  selected: part.id == selected,
                  onTap: () =>
                      ref.read(selectedPartProvider.notifier).select(part.id),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          title: 'Материал · ${filament.title}',
          trailing: filament.label,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final id in FilamentId.values)
                    _Chip(
                      label: filamentOf(id).title,
                      selected: id == filament.id,
                      onTap: () => ref
                          .read(configProvider.notifier)
                          .setFilament(selected, id),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(filament.note, style: text.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Panel(
          title: 'Цвет детали · ${colorName(color)}',
          trailing:
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final swatch in kFilamentColors)
                _Swatch(
                  swatch: swatch,
                  selected: swatch.color.toARGB32() == color.toARGB32(),
                  onTap: () => ref
                      .read(configProvider.notifier)
                      .setColor(selected, swatch),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Details(config: config, quote: quote),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.accent.withValues(alpha: 0.16), c.panel],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.accent.withValues(alpha: 0.35)),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 18,
            runSpacing: 14,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Итого за набор'.toUpperCase(), style: text.labelSmall),
                  const SizedBox(height: 4),
                  Text(rub(quote.total), style: text.headlineMedium),
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ModButton(
                    label: 'Ссылка на сборку',
                    compact: true,
                    style: ModButtonStyle.ghost,
                    onPressed: () async {
                      final link = ref
                          .read(configProvider.notifier)
                          .shareLink
                          .toString();
                      await Clipboard.setData(ClipboardData(text: link));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: c.panelRaised,
                          content: Text(
                            'Ссылка на сборку скопирована',
                            style: text.bodyMedium,
                          ),
                        ),
                      );
                    },
                  ),
                  ModButton(
                    label: 'В корзину',
                    compact: true,
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: c.panelRaised,
                        content: Text(
                          'Набор на ${rub(quote.total)} добавлен в корзину',
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
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.trailing,
    required this.child,
    this.onTap,
  });

  final String title;
  final String trailing;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.panel.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_header(context, text), const SizedBox(height: 14), child],
      ),
    );
  }
}

extension on _Panel {
  Widget _header(BuildContext context, TextTheme text) {
    final row = Row(
      children: [
        Expanded(child: Text(title.toUpperCase(), style: text.labelSmall)),
        Text(trailing.toUpperCase(), style: text.labelSmall),
      ],
    );
    if (onTap == null) return row;
    return HotZone(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          mouseCursor: MouseCursor.defer,
          child: row,
        ),
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  const _PartRow({
    required this.part,
    required this.color,
    required this.filament,
    required this.selected,
    required this.onTap,
  });

  final CasePart part;
  final Color color;
  final Filament filament;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: HotZone(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            mouseCursor: MouseCursor.defer,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              decoration: BoxDecoration(
                color: selected
                    ? Color.alphaBlend(
                        c.accent.withValues(alpha: 0.12),
                        c.panelRaised,
                      )
                    : c.panelRaised.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? c.accent : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          part.name,
                          style: text.bodyMedium?.copyWith(
                            color: c.ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                          ),
                        ),
                        Text(
                          '${filament.label} · ${colorName(color)} · ${grams(part.grams)}'
                              .toUpperCase(),
                          style: text.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    rub(part.grams * filament.pricePerGram),
                    style: text.labelLarge?.copyWith(color: c.inkSoft),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    return HotZone(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          mouseCursor: MouseCursor.defer,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? c.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: selected ? c.accent : c.line),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : c.inkSoft,
                fontSize: 11.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  final FilamentColor swatch;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    return Tooltip(
      message: swatch.name,
      child: HotZone(
        // Кнопка, а не GestureDetector: нужен фокус с клавиатуры,
        // роль и состояние «выбрано» для скринридера.
        child: Semantics(
          button: true,
          selected: selected,
          label: 'Цвет ${swatch.name}',
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(9),
              mouseCursor: MouseCursor.defer,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: swatch.color,
                  borderRadius: BorderRadius.circular(9),
                  gradient: swatch.silk
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.alphaBlend(
                              Colors.white.withValues(alpha: 0.45),
                              swatch.color,
                            ),
                            swatch.color,
                            Color.alphaBlend(
                              Colors.white.withValues(alpha: 0.28),
                              swatch.color,
                            ),
                          ],
                        )
                      : null,
                  border: Border.all(
                    color: selected
                        ? c.ink
                        : Colors.white.withValues(alpha: 0.16),
                    width: selected ? 2 : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Технические подробности спрятаны, но не выброшены: пресеты можно
/// скачать и напечатать самому, и тогда все эти цифры нужны.
class _Details extends StatefulWidget {
  const _Details({required this.config, required this.quote});

  final CaseConfiguration config;
  final Quote quote;

  @override
  State<_Details> createState() => _DetailsState();
}

class _DetailsState extends State<_Details> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    final text = Theme.of(context).textTheme;

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Expanded(child: Text(label.toUpperCase(), style: text.labelSmall)),
          Text(value, style: text.labelLarge?.copyWith(color: c.inkSoft)),
        ],
      ),
    );

    return _Panel(
      title: 'Характеристики',
      trailing: _open ? 'свернуть' : 'для тех, кто печатает сам',
      onTap: () => setState(() => _open = !_open),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 220),
        crossFadeState: _open
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox(width: double.infinity),
        secondChild: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            row('пластика в наборе', grams(widget.quote.grams)),
            row('время печати', hoursMinutes(widget.quote.hours)),
            for (final part in kParts)
              row(
                part.name,
                '${widget.config.filamentOf(part.id).label} · '
                '${widget.config.filamentOf(part.id).tempLabel}',
              ),
          ],
        ),
      ),
    );
  }
}
