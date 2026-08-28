import 'package:flutter/material.dart';

import 'mod_colors.dart';

/// Три гарнитуры, все с кириллицей:
/// Nunito — дисплейные заголовки, Nunito Sans — текст,
/// JetBrains Mono — данные, цены и состояние фермы.
///
/// Файлы лежат в `assets/fonts`, а не тянутся из сети в рантайме:
/// иначе первая отрисовка ждёт ответа Google, а без сети ломается совсем.
abstract final class ModType {
  static const display = 'Nunito';
  static const body = 'Nunito Sans';
  static const data = 'JetBrains Mono';

  /// tracking в вёрстке задан в `em`, у Flutter — в логических пикселях.
  static double _tracking(double size, double em) => size * em;

  static TextStyle displayStyle(
    double size, {
    FontWeight weight = FontWeight.w800,
  }) => TextStyle(
    fontFamily: display,
    fontSize: size,
    fontWeight: weight,
    height: 1.06,
    letterSpacing: _tracking(size, -0.02),
  );

  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w400,
    double em = 0.12,
  }) => TextStyle(
    fontFamily: data,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: _tracking(size, em),
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle _body(double size, double height, Color color) =>
      TextStyle(fontFamily: body, fontSize: size, height: height, color: color);

  static TextTheme textTheme(ModColors c) => TextTheme(
    displayLarge: displayStyle(64).copyWith(color: c.ink),
    displayMedium: displayStyle(44).copyWith(color: c.ink),
    headlineLarge: displayStyle(38).copyWith(color: c.ink),
    headlineMedium: displayStyle(26).copyWith(color: c.ink),
    titleLarge: displayStyle(
      19,
      weight: FontWeight.w700,
    ).copyWith(color: c.ink),
    bodyLarge: _body(16.5, 1.6, c.inkSoft),
    bodyMedium: _body(15, 1.55, c.inkSoft),
    bodySmall: _body(13.5, 1.5, c.muted),
    labelLarge: mono(
      12.5,
      weight: FontWeight.w600,
      em: 0.06,
    ).copyWith(color: c.ink),
    labelMedium: mono(11, em: 0.22).copyWith(color: c.muted),
    labelSmall: mono(10, em: 0.16).copyWith(color: c.dim),
  );
}
