import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Хранилище подставляется в `main`, чтобы провайдеры оставались
/// синхронными и не разъезжались на первом кадре.
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('prefsProvider не переопределён в ProviderScope'),
);
