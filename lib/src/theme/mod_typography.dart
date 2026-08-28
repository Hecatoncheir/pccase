
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mod_colors.dart';

/// Три гарнитуры, все с кириллицей:
/// Nunito — дисплейные заголовки, Nunito Sans — текст,
/// JetBrains Mono — данные, цены и состояние фермы.
///
/// Для продакшена шрифты стоит положить в `assets/fonts` и подключить
/// через `pubspec.yaml`, чтобы первая отрисовка не ждала сеть.
abstract final class ModType {
  /// tracking в вёрстке задан в `em`, у Flutter — в логических пикселях.
  static double _tracking(double size, double em) => size * em;

  static TextStyle display(double size, {FontWeight weight = FontWeight.w800}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight,
        height: 1.06,
        letterSpacing: _tracking(size, -0.02),
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
        headlineMedium: display(26).copyWith(color: c.ink),
        titleLarge: display(19, weight: FontWeight.w700).copyWith(color: c.ink),
        bodyLarge: GoogleFonts.nunitoSans(
          fontSize: 16.5,
          height: 1.6,
          color: c.inkSoft,
        ),
        bodyMedium: GoogleFonts.nunitoSans(
          fontSize: 15,
          height: 1.55,
          color: c.inkSoft,
        ),
        bodySmall: GoogleFonts.nunitoSans(
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
