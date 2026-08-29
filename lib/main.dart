import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/state/prefs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ссылка на сборку живёт в обычном query-параметре, без решётки.
  usePathUrlStrategy();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: const ModCaseApp(),
    ),
  );
}
