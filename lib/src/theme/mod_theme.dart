import 'package:flutter/material.dart';

import '../domain/preset.dart';
import 'mod_colors.dart';
import 'mod_typography.dart';

ThemeData buildModTheme(Preset preset, Brightness brightness) {
  final c = ModColors.of(preset, brightness);
  final text = ModType.textTheme(c);
  final onAccent = c.isDark ? const Color(0xFF08090C) : Colors.white;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: c.plate,
    canvasColor: c.plate,
    textTheme: text,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: onAccent,
      secondary: c.silk,
      onSecondary: onAccent,
      surface: c.panel,
      onSurface: c.ink,
      outline: c.line,
      error: c.mid,
      onError: onAccent,
    ),
    dividerColor: c.lineSoft,
    splashFactory: NoSplash.splashFactory,
    extensions: <ThemeExtension<dynamic>>[c],
  );
}
