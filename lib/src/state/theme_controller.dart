import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prefs.dart';

const _themeKey = 'theme';

/// По умолчанию идём за системой, дальше — как переключит пользователь,
/// и выбор переживает перезагрузку.
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.read(prefsProvider).getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  /// Переключаем от того, что человек видит сейчас, а не от режима:
  /// из `system` иначе не выбраться одним нажатием.
  void toggle(Brightness current) {
    state = current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    ref.read(prefsProvider).setString(_themeKey, state.name);
  }
}
