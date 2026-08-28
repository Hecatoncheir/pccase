import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/case_part.dart';
import '../domain/configuration.dart';
import '../domain/filament.dart';
import '../domain/filament_color.dart';
import '../domain/preset.dart';

/// Активный пресет задаёт тему целиком: акцент, свечение, подсветку корпуса.
final presetProvider = NotifierProvider<PresetController, Preset>(
  PresetController.new,
);

class PresetController extends Notifier<Preset> {
  @override
  Preset build() => kPresets.first;

  void select(Preset preset) {
    state = preset;
    ref.read(configProvider.notifier).applyPreset(preset);
  }
}

/// Конфигурация набора.
final configProvider = NotifierProvider<ConfigController, CaseConfiguration>(
  ConfigController.new,
);

class ConfigController extends Notifier<CaseConfiguration> {
  @override
  CaseConfiguration build() => CaseConfiguration.fromPreset(kPresets.first);

  void applyPreset(Preset preset) =>
      state = CaseConfiguration.fromPreset(preset);

  void setColor(PartId part, FilamentColor color) =>
      state = state.withColor(part, color.color);

  void setFilament(PartId part, FilamentId filament) =>
      state = state.withFilament(part, filament);
}

/// Деталь, которую сейчас правят в конструкторе.
final selectedPartProvider = NotifierProvider<SelectedPart, PartId>(
  SelectedPart.new,
);

class SelectedPart extends Notifier<PartId> {
  @override
  PartId build() => PartId.front;

  void select(PartId part) => state = part;
}

/// Смета пересчитывается сама при любом изменении конфигурации.
final quoteProvider = Provider<Quote>(
  (ref) => quoteFor(ref.watch(configProvider)),
);
