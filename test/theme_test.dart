import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pccase/src/domain/preset.dart';
import 'package:pccase/src/theme/mod_colors.dart';

/// Отношение контраста по WCAG.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('светлая тема', () {
    test('акцент каждого пресета читается на светлом грунте', () {
      for (final preset in kPresets) {
        final c = ModColors.light(preset);
        expect(
          contrast(c.accent, c.plate),
          greaterThanOrEqualTo(3.4),
          reason: 'акцент пресета ${preset.name} теряется на белом',
        );
      }
    });

    test('текстовые токены проходят порог для мелкого текста', () {
      final c = ModColors.light(kPresets.first);
      for (final entry in {
        'ink': c.ink,
        'muted': c.muted,
        'dim': c.dim,
      }.entries) {
        expect(
          contrast(entry.value, c.panel),
          greaterThanOrEqualTo(4.5),
          reason: '${entry.key} не дотягивает до 4.5:1 на карточке',
        );
      }
    });

    test('эффекты переключаются с аддитивного смешивания', () {
      expect(ModColors.light(kPresets.first).glowBlend, BlendMode.srcOver);
      expect(ModColors.dark(kPresets.first).glowBlend, BlendMode.plus);
    });
  });

  group('тёмная тема', () {
    test('акцент пресета берётся как есть', () {
      for (final preset in kPresets) {
        expect(ModColors.dark(preset).accent, preset.accent);
      }
    });

    test('текст читается на грунте', () {
      final c = ModColors.dark(kPresets.first);
      expect(contrast(c.ink, c.plate), greaterThanOrEqualTo(4.5));
      expect(contrast(c.muted, c.plate), greaterThanOrEqualTo(3.0));
    });
  });

  test('переход между темами не застревает на середине', () {
    final dark = ModColors.dark(kPresets.first);
    final light = ModColors.light(kPresets.first);
    final half = dark.lerp(light, 0.5);

    expect(half.brightness, Brightness.light);
    expect(half.plate, Color.lerp(dark.plate, light.plate, 0.5));
    expect(half.accent, isNot(dark.accent));
  });
}
