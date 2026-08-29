import 'package:flutter_test/flutter_test.dart';
import 'package:pccase/src/domain/case_part.dart';
import 'package:pccase/src/domain/configuration.dart';
import 'package:pccase/src/domain/filament.dart';
import 'package:pccase/src/domain/preset.dart';
import 'package:pccase/src/ui/format.dart';

void main() {
  group('смета набора', () {
    final ember = CaseConfiguration.fromPreset(presetOf('ember'));

    test('масса не зависит от материалов', () {
      expect(ember.grams, 616);
      expect(quoteFor(ember).grams, 616);
    });

    test('пресет Ember Cyan считается так же, как в концепте', () {
      final quote = quoteFor(ember);
      expect(quote.plastic, closeTo(3566.8, 0.01));
      expect(quote.hours, closeTo(78.93, 0.01));
      expect(rub(quote.total), '8 609 ₽');
    });

    test('срок считается от часов печати, а не равен им', () {
      final quote = quoteFor(ember);
      // 79 часов печати — это не 79 часов ожидания: ферма печатает
      // детали параллельно.
      expect(quote.hours, greaterThan(78));
      expect(quote.readyInDays, 4);

      final quick = quoteFor(
        CaseConfiguration(
          colors: ember.colors,
          filaments: {for (final part in kParts) part.id: FilamentId.pla},
        ),
      );
      expect(quick.readyInDays, lessThanOrEqualTo(quote.readyInDays));
    });

    test('смена материала детали меняет цену и время', () {
      final cheaper = ember.withFilament(PartId.front, FilamentId.pla);
      final before = quoteFor(ember);
      final after = quoteFor(cheaper);

      expect(after.total, lessThan(before.total));
      expect(after.hours, lessThan(before.hours));
      expect(after.grams, before.grams);
    });

    test('конфигурация иммутабельна', () {
      final changed = ember.withFilament(PartId.side, FilamentId.pla);
      expect(ember.filamentIdOf(PartId.side), FilamentId.asa);
      expect(changed.filamentIdOf(PartId.side), FilamentId.pla);
      expect(changed.presetId, isNull);
    });
  });

  group('форматирование', () {
    // Внимание: в ожиданиях ниже стоит неразрывный пробел (U+00A0),
    // тот же, что возвращает format.dart — обычный пробел тест уронит.
    test('разряды разделяются неразрывным пробелом', () {
      expect(rub(8608.74), '8 609 ₽');
      expect(rub(990), '990 ₽');
      expect(grams(616), '616 г');
      expect(hoursMinutes(78.932), '78 ч 56 мин');
    });
  });
}
