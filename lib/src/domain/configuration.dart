import 'package:flutter/material.dart';

import 'case_part.dart';
import 'filament.dart';
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

  CaseConfiguration withColor(PartId id, Color color) => CaseConfiguration(
        colors: {...colors, id: color},
        filaments: filaments,
      );

  CaseConfiguration withFilament(PartId id, FilamentId filament) =>
      CaseConfiguration(
        colors: colors,
        filaments: {...filaments, id: filament},
      );

  int get grams => kParts.fold(0, (sum, part) => sum + part.grams);

  int get materialCount => filaments.values.toSet().length;
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
