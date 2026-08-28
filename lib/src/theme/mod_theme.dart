import 'package:flutter/material.dart';

import '../domain/preset.dart';
import 'mod_colors.dart';
import 'mod_typography.dart';

ThemeData buildModTheme(Preset preset) {
  final c = ModColors.fromPreset(preset);
  final text = ModType.textTheme(c);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: c.plate,
    canvasColor: c.plate,
    textTheme: text,
    colorScheme: ColorScheme.dark(
      primary: c.accent,
      onPrimary: const Color(0xFF08090C),
      secondary: c.silk,
      onSecondary: const Color(0xFF08090C),
      surface: c.panel,
      onSurface: c.ink,
      outline: c.line,
      error: c.mid,
    ),
    dividerColor: c.lineSoft,
    splashFactory: NoSplash.splashFactory,
    extensions: <ThemeExtension<dynamic>>[c],
  );
}
