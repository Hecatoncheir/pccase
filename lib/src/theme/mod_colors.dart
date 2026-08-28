import 'package:flutter/material.dart';

import '../domain/preset.dart';

/// Токены палитры. Ровно те же значения, что в `design/modcase-concept.html`,
/// поэтому концепт и приложение не разъезжаются.
///
/// Живёт как [ThemeExtension], значит переключение пресета анимируется
/// самим `MaterialApp` через `AnimatedTheme` — палитра интерполируется.
@immutable
class ModColors extends ThemeExtension<ModColors> {
  const ModColors({
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

  /// Стартовая схема — пресет Ember Cyan.
  static final ModColors dark = ModColors.fromPreset(kPresets.first);

  factory ModColors.fromPreset(Preset preset) => ModColors(
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

  /// Грунт: сине-смещённый чёрный, а не нейтральный серый.
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

  /// Акцент активной схемы. Меняется вместе с пресетом.
  final Color accent;
  final Color accentAlt;

  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color dim;

  /// Фирменный градиент — та самая температурная рампа.
  LinearGradient get ramp => LinearGradient(
        colors: [cold, mid, hot],
        stops: const [0, 0.46, 0.84],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  /// Свечение под курсором и вокруг активной детали.
  RadialGradient get accentGlow => RadialGradient(
        colors: [accent.withValues(alpha: 0.16), Colors.transparent],
        stops: const [0, 0.68],
      );

  @override
  ModColors copyWith({
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
