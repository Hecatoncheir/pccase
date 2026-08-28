import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/config_controller.dart';
import 'state/theme_controller.dart';
import 'theme/mod_theme.dart';
import 'ui/home_page.dart';
import 'ui/widgets/pointer_field.dart';

class ModCaseApp extends ConsumerWidget {
  const ModCaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Пресет задаёт тему целиком: смена акцента анимируется
    // встроенным в MaterialApp AnimatedTheme.
    final preset = ref.watch(presetProvider);

    return MaterialApp(
      title: 'MODCASE Hyper',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(themeModeProvider),
      theme: buildModTheme(preset, Brightness.light),
      darkTheme: buildModTheme(preset, Brightness.dark),
      home: const Scaffold(body: PointerField(child: HomePage())),
    );
  }
}
