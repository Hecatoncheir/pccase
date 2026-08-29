import 'package:flutter_test/flutter_test.dart';
import 'package:pccase/src/domain/case_part.dart';
import 'package:pccase/src/domain/configuration.dart';
import 'package:pccase/src/domain/filament.dart';
import 'package:pccase/src/domain/preset.dart';

void main() {
  group('код сборки для ссылки', () {
    test('каждый пресет переживает круг «код — разбор»', () {
      for (final preset in kPresets) {
        final original = CaseConfiguration.fromPreset(preset);
        final restored = CaseConfiguration.fromCode(original.toCode());

        expect(restored, isNotNull, reason: preset.name);
        for (final part in kParts) {
          expect(restored!.colorOf(part.id), original.colorOf(part.id));
          expect(
            restored.filamentIdOf(part.id),
            original.filamentIdOf(part.id),
          );
        }
      }
    });

    test('код — два символа на деталь', () {
      final code = CaseConfiguration.fromPreset(kPresets.first).toCode();
      expect(code.length, kParts.length * 2);
    });

    test('ручная правка тоже кодируется', () {
      final changed = CaseConfiguration.fromPreset(kPresets.first)
          .withFilament(PartId.front, FilamentId.asa);
      final restored = CaseConfiguration.fromCode(changed.toCode());

      expect(restored!.filamentIdOf(PartId.front), FilamentId.asa);
      expect(restored.presetId, isNull);
    });

    test('мусор в ссылке не разбирается', () {
      for (final code in <String?>[
        null,
        '',
        'короткий',
        'zzzzzzzzzzzz', // цвета с таким номером нет
        '0z0z0z0z0z0z', // материала с таким номером нет
        'a0b1c2d3e4f5g6', // длиннее, чем деталей
      ]) {
        expect(
          CaseConfiguration.fromCode(code),
          isNull,
          reason: 'код «$code» не должен разбираться',
        );
      }
    });
  });
}
