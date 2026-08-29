import 'package:flutter/material.dart';

import 'case_part.dart';
import 'filament.dart';
import 'filament_color.dart';
import 'preset.dart';

/// Иммутабельная конфигурация набора. Цена, масса и время печати —
/// чистые функции от неё (см. [Quote]), поэтому те же формулы
/// переиспользует бэкенд при подтверждении заказа.
@immutable
class CaseConfiguration {
  const CaseConfiguration({
    required this.colors,
    required this.filaments,
    this.presetId,
  });

  factory CaseConfiguration.fromPreset(Preset preset) => CaseConfiguration(
    colors: Map.unmodifiable(preset.colors),
    filaments: Map.unmodifiable(preset.filaments),
    presetId: preset.id,
  );

  final Map<PartId, Color> colors;
  final Map<PartId, FilamentId> filaments;

  /// `null`, если пользователь ушёл от пресета руками.
  final String? presetId;

  Color colorOf(PartId id) => colors[id]!;
  FilamentId filamentIdOf(PartId id) => filaments[id]!;
  Filament filamentOf(PartId id) => kFilaments[filaments[id]]!;

  CaseConfiguration withColor(PartId id, Color color) =>
      CaseConfiguration(colors: {...colors, id: color}, filaments: filaments);

  CaseConfiguration withFilament(PartId id, FilamentId filament) =>
      CaseConfiguration(
        colors: colors,
        filaments: {...filaments, id: filament},
      );

  int get grams => kParts.fold(0, (sum, part) => sum + part.grams);

  int get materialCount => filaments.values.toSet().length;

  /// Компактный код сборки для ссылки: на каждую деталь два символа —
  /// цвет из палитры и материал. Шесть деталей укладываются в 12 знаков.
  String toCode() {
    final buffer = StringBuffer();
    for (final part in kParts) {
      final color = kFilamentColors.indexWhere(
        (c) => c.color.toARGB32() == colors[part.id]!.toARGB32(),
      );
      final filament = FilamentId.values.indexOf(filaments[part.id]!);
      if (color < 0) return '';
      buffer
        ..write(color.toRadixString(36))
        ..write(filament.toRadixString(36));
    }
    return buffer.toString();
  }

  /// Разбирает код из ссылки. Возвращает `null` на любой мусор —
  /// чужую ссылку править молча нельзя.
  static CaseConfiguration? fromCode(String? code) {
    if (code == null || code.length != kParts.length * 2) return null;

    final colors = <PartId, Color>{};
    final filaments = <PartId, FilamentId>{};
    for (var i = 0; i < kParts.length; i++) {
      final color = int.tryParse(code[i * 2], radix: 36);
      final filament = int.tryParse(code[i * 2 + 1], radix: 36);
      if (color == null || color >= kFilamentColors.length) return null;
      if (filament == null || filament >= FilamentId.values.length) return null;
      colors[kParts[i].id] = kFilamentColors[color].color;
      filaments[kParts[i].id] = FilamentId.values[filament];
    }
    return CaseConfiguration(colors: colors, filaments: filaments);
  }
}

/// Смета набора. Ставки демонстрационные — их место в настройках фермы.
@immutable
class Quote {
  const Quote({
    required this.grams,
    required this.hours,
    required this.plastic,
    required this.labor,
    required this.assembly,
  });

  static const double hourlyRate = 45;
  static const double assemblyFee = 1490;

  final int grams;
  final double hours;
  final double plastic;
  final double labor;
  final double assembly;

  double get total => plastic + labor + assembly;

  /// Через сколько дней набор уедет к покупателю. Часы печати сами по себе
  /// пугают («78 часов!»), хотя на ферме детали печатаются параллельно:
  /// трое суток на очередь, сборку и упаковку плюс сутки на каждые
  /// сорок часов печати.
  int get readyInDays => 3 + (hours / 40).floor();
}

Quote quoteFor(CaseConfiguration config) {
  var grams = 0;
  var hours = 0.0;
  var plastic = 0.0;

  for (final part in kParts) {
    final filament = config.filamentOf(part.id);
    grams += part.grams;
    hours += part.grams * filament.hoursPerGram;
    plastic += part.grams * filament.pricePerGram;
  }

  return Quote(
    grams: grams,
    hours: hours,
    plastic: plastic,
    labor: hours * Quote.hourlyRate,
    assembly: Quote.assemblyFee,
  );
}
