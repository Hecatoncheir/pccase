import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pccase/src/app.dart';
import 'package:pccase/src/domain/case_part.dart';
import 'package:pccase/src/domain/configuration.dart';
import 'package:pccase/src/domain/filament.dart';
import 'package:pccase/src/domain/preset.dart';
import 'package:pccase/src/state/config_controller.dart';
import 'package:pccase/src/state/prefs.dart';
import 'package:pccase/src/state/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  Map<String, Object> storage = const {},
}) async {
  SharedPreferences.setMockInitialValues(storage);
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const ModCaseApp(),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
}

void main() {
  testWidgets('страница собирается и переживает смену темы', (tester) async {
    final container = await pumpApp(tester);

    expect(find.text('Корпус, который'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Тему читаем ниже MaterialApp: на его собственном элементе
    // Theme.of вернёт тему-предка, а не ту, что вставляет приложение.
    Brightness shownBrightness() =>
        Theme.of(tester.element(find.byType(Scaffold))).brightness;

    final before = shownBrightness();
    container.read(themeModeProvider.notifier).toggle(before);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(shownBrightness(), isNot(before));
    expect(tester.takeException(), isNull);
  });

  testWidgets('выбор темы восстанавливается из хранилища', (tester) async {
    final container = await pumpApp(tester, storage: {'theme': 'light'});
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  testWidgets('сборка восстанавливается из прошлого захода', (tester) async {
    final saved = CaseConfiguration.fromPreset(presetOf('toxic'))
        .withFilament(PartId.comb, FilamentId.asa);

    final container = await pumpApp(tester, storage: {'build': saved.toCode()});
    final restored = container.read(configProvider);

    expect(restored.filamentIdOf(PartId.comb), FilamentId.asa);
    expect(
      restored.colorOf(PartId.side),
      presetOf('toxic').colors[PartId.side],
    );
  });
}
