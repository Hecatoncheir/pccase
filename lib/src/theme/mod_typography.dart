
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mod_colors.dart';

/// Три гарнитуры, все с кириллицей:
/// Unbounded — дисплейные заголовки, Manrope — текст,
/// JetBrains Mono — данные, цены и состояние фермы.
///
/// Для продакшена шрифты стоит положить в `assets/fonts` и подключить
/// через `pubspec.yaml`, чтобы первая отрисовка не ждала сеть.
abstract final class ModType {
  /// tracking в вёрстке задан в `em`, у Flutter — в логических пикселях.
  static double _tracking(double size, double em) => size * em;

  static TextStyle display(double size, {FontWeight weight = FontWeight.w800}) =>
      GoogleFonts.unbounded(
        fontSize: size,
        fontWeight: weight,
        height: 1.02,
        letterSpacing: _tracking(size, -0.035),
      );

  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w400,
    double em = 0.12,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: _tracking(size, em),
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static TextTheme textTheme(ModColors c) => TextTheme(
        displayLarge: display(64).copyWith(color: c.ink),
        displayMedium: display(44).copyWith(color: c.ink),
        headlineLarge: display(38).copyWith(color: c.ink),
        headlineMedium: display(26, weight: FontWeight.w600)
            .copyWith(color: c.ink, letterSpacing: _tracking(26, -0.02)),
        titleLarge: display(19, weight: FontWeight.w600)
            .copyWith(color: c.ink, letterSpacing: _tracking(19, -0.02)),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16.5,
          height: 1.6,
          color: c.inkSoft,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 15,
          height: 1.55,
          color: c.inkSoft,
        ),
        bodySmall: GoogleFonts.manrope(
          fontSize: 13.5,
          height: 1.5,
          color: c.muted,
        ),
        labelLarge: mono(12.5, weight: FontWeight.w600, em: 0.06)
            .copyWith(color: c.ink),
        labelMedium: mono(11, em: 0.22).copyWith(color: c.muted),
        labelSmall: mono(10, em: 0.16).copyWith(color: c.dim),
      );
}
