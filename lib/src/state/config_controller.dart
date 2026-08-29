import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/case_part.dart';
import '../domain/configuration.dart';
import '../domain/filament.dart';
import '../domain/filament_color.dart';
import '../domain/preset.dart';
import 'prefs.dart';

const _buildKey = 'build';

/// Схема, от которой берётся акцент темы. Пресет в конфигурации может
/// пропасть (человек поменял цвет руками) — акцент при этом остаётся
/// от последней выбранной схемы.
final presetProvider = NotifierProvider<PresetController, Preset>(
  PresetController.new,
);

class PresetController extends Notifier<Preset> {
  @override
  Preset build() {
    final id = ref.read(configProvider).presetId;
    return kPresets.firstWhere((p) => p.id == id, orElse: () => kPresets.first);
  }

  void select(Preset preset) {
    state = preset;
    ref.read(configProvider.notifier).applyPreset(preset);
  }
}

/// Конфигурация набора. Восстанавливается из ссылки, а если её нет —
/// из прошлого захода.
final configProvider = NotifierProvider<ConfigController, CaseConfiguration>(
  ConfigController.new,
);

class ConfigController extends Notifier<CaseConfiguration> {
  @override
  CaseConfiguration build() {
    final fromLink = CaseConfiguration.fromCode(Uri.base.queryParameters['p']);
    final saved = CaseConfiguration.fromCode(
      ref.read(prefsProvider).getString(_buildKey),
    );
    return fromLink ?? saved ?? CaseConfiguration.fromPreset(kPresets.first);
  }

  void applyPreset(Preset preset) => _set(CaseConfiguration.fromPreset(preset));

  void setColor(PartId part, FilamentColor color) =>
      _set(state.withColor(part, color.color));

  void setFilament(PartId part, FilamentId filament) =>
      _set(state.withFilament(part, filament));

  /// Ссылка на текущую сборку — её можно отдать другому человеку.
  Uri get shareLink {
    final code = state.toCode();
    return Uri.base.replace(
      queryParameters: code.isEmpty ? null : {'p': code},
      fragment: '',
    );
  }

  void _set(CaseConfiguration next) {
    state = next;
    final code = next.toCode();
    if (code.isEmpty) return;

    ref.read(prefsProvider).setString(_buildKey, code);
    // Адресная строка идёт следом за сборкой, чтобы ссылку можно было
    // просто скопировать из браузера.
    SystemNavigator.routeInformationUpdated(
      uri: Uri(path: Uri.base.path, queryParameters: {'p': code}),
      replace: true,
    );
  }
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
