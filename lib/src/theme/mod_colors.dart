import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/preset.dart';

/// Токены палитры. Значения совпадают с `design/modcase-concept.html`,
/// поэтому концепт и приложение не разъезжаются.
///
/// Живёт как [ThemeExtension], значит и смена пресета, и переключение
/// светлой темы анимируются `AnimatedTheme` — палитра интерполируется.
@immutable
class ModColors extends ThemeExtension<ModColors> {
  const ModColors({
    required this.brightness,
    required this.plate,
    required this.plateDeep,
    required this.panel,
    required this.panelRaised,
    required this.line,
    required this.lineSoft,
    required this.cold,
    required this.mid,
    required this.hot,
    required this.silk,
    required this.accent,
    required this.accentAlt,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.dim,
  });

  /// Тёмная — «рабочий стол слайсера»: сине-смещённый чёрный грунт,
  /// рампа светится.
  factory ModColors.dark(Preset preset) => ModColors(
    brightness: Brightness.dark,
    plate: const Color(0xFF060911),
    plateDeep: const Color(0xFF03060C),
    panel: const Color(0xFF0B1020),
    panelRaised: const Color(0xFF121A2E),
    line: const Color(0xFF1E2740),
    lineSoft: const Color(0xFF161E33),
    cold: const Color(0xFF2BB8FF),
    mid: const Color(0xFFFF2D8F),
    hot: const Color(0xFFFF4A1C),
    silk: const Color(0xFF16F2AE),
    accent: preset.accent,
    accentAlt: preset.accentAlt,
    ink: const Color(0xFFE9EEFC),
    inkSoft: const Color(0xFFB7C2DC),
    muted: const Color(0xFF7E8CAC),
    dim: const Color(0xFF56617E),
  );

  /// Светлая — «гладкий PEI-стол под лампой»: холодный белый грунт с тем же
  /// синим смещением, рампа уходит в насыщенные тона, иначе она теряется
  /// на белом. Это не инверсия: свечение здесь не работает, поэтому роль
  /// акцента берут на себя насыщенность и контраст.
  factory ModColors.light(Preset preset) {
    const ground = Color(0xFFEEF1F8);
    return ModColors(
      brightness: Brightness.light,
      plate: ground,
      plateDeep: const Color(0xFFDDE3F0),
      panel: Colors.white,
      panelRaised: const Color(0xFFF1F4FB),
      line: const Color(0xFFCBD4E6),
      lineSoft: const Color(0xFFDFE5F1),
      cold: const Color(0xFF0B7FC4),
      mid: const Color(0xFFD5157A),
      hot: const Color(0xFFD93B10),
      silk: const Color(0xFF0A8460),
      accent: _readableOn(preset.accent, ground),
      accentAlt: _readableOn(preset.accentAlt, ground),
      ink: const Color(0xFF0B1120),
      inkSoft: const Color(0xFF37425A),
      muted: const Color(0xFF4E5872),
      dim: const Color(0xFF68728B),
    );
  }

  factory ModColors.of(Preset preset, Brightness brightness) =>
      brightness == Brightness.dark
      ? ModColors.dark(preset)
      : ModColors.light(preset);

  final Brightness brightness;

  /// Грунт страницы.
  final Color plate;
  final Color plateDeep;
  final Color panel;
  final Color panelRaised;
  final Color line;
  final Color lineSoft;

  /// Температурная рампа: холодный стол → расплав.
  final Color cold;
  final Color mid;
  final Color hot;
  final Color silk;

  /// Акцент активной схемы. На светлом грунте затемняется до читаемого.
  final Color accent;
  final Color accentAlt;

  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color dim;

  bool get isDark => brightness == Brightness.dark;

  /// На тёмном эффекты складываются светом, на светлом — обычным наложением:
  /// аддитивное смешивание на белом даёт белое пятно.
  BlendMode get glowBlend => isDark ? BlendMode.plus : BlendMode.srcOver;

  /// Фирменный градиент — та самая температурная рампа.
  LinearGradient get ramp => LinearGradient(
    colors: [cold, mid, hot],
    stops: const [0, 0.46, 0.84],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Свечение под курсором: на светлом оно слабее, иначе грязнит фон.
  double get glowStrength => isDark ? 0.16 : 0.09;

  /// Капля расплава в следе курсора.
  Color get molten =>
      isDark ? const Color(0xFFFFD9A8) : const Color(0xFFFF6A1F);

  /// Затемняем цвет, пока он не начнёт читаться на светлом грунте.
  static Color _readableOn(Color color, Color ground) {
    var hsl = HSLColor.fromColor(color);
    while (_contrast(hsl.toColor(), ground) < 3.4 && hsl.lightness > 0.24) {
      hsl = hsl.withLightness(math.max(0.24, hsl.lightness - 0.035));
    }
    // Затемнение выцвечивает тон — возвращаем насыщенность.
    return hsl.withSaturation(math.min(1, hsl.saturation + 0.08)).toColor();
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  @override
  ModColors copyWith({
    Brightness? brightness,
    Color? plate,
    Color? plateDeep,
    Color? panel,
    Color? panelRaised,
    Color? line,
    Color? lineSoft,
    Color? cold,
    Color? mid,
    Color? hot,
    Color? silk,
    Color? accent,
    Color? accentAlt,
    Color? ink,
    Color? inkSoft,
    Color? muted,
    Color? dim,
  }) {
    return ModColors(
      brightness: brightness ?? this.brightness,
      plate: plate ?? this.plate,
      plateDeep: plateDeep ?? this.plateDeep,
      panel: panel ?? this.panel,
      panelRaised: panelRaised ?? this.panelRaised,
      line: line ?? this.line,
      lineSoft: lineSoft ?? this.lineSoft,
      cold: cold ?? this.cold,
      mid: mid ?? this.mid,
      hot: hot ?? this.hot,
      silk: silk ?? this.silk,
      accent: accent ?? this.accent,
      accentAlt: accentAlt ?? this.accentAlt,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      muted: muted ?? this.muted,
      dim: dim ?? this.dim,
    );
  }

  @override
  ModColors lerp(covariant ModColors? other, double t) {
    if (other == null) return this;
    return ModColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      plate: Color.lerp(plate, other.plate, t)!,
      plateDeep: Color.lerp(plateDeep, other.plateDeep, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      panelRaised: Color.lerp(panelRaised, other.panelRaised, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineSoft: Color.lerp(lineSoft, other.lineSoft, t)!,
      cold: Color.lerp(cold, other.cold, t)!,
      mid: Color.lerp(mid, other.mid, t)!,
      hot: Color.lerp(hot, other.hot, t)!,
      silk: Color.lerp(silk, other.silk, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentAlt: Color.lerp(accentAlt, other.accentAlt, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      dim: Color.lerp(dim, other.dim, t)!,
    );
  }
}

extension ModColorsX on BuildContext {
  /// Токены текущей темы: `context.mod.accent`.
  ModColors get mod => Theme.of(this).extension<ModColors>()!;
}
