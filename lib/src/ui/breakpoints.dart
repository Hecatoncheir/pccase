import 'package:flutter/widgets.dart';

/// Пороги раскладки в одном месте: раньше 1040, 700 и 620 были рассыпаны
/// магическими числами по виджетам, и менять их приходилось поиском.
abstract final class Breakpoints {
  /// Дальше этой ширины контент не растягивается.
  static const double content = 1280;

  /// Ниже — колонки складываются в одну, ссылки в шапке прячутся.
  static const double wide = 1040;

  /// Ниже — крупный дисплейный кегль не помещается.
  static const double roomyType = 700;

  /// Ниже — строка состояния фермы показывает только начало.
  static const double statusFull = 620;

  /// Ниже — узкие поля по краям.
  static const double tightGutter = 600;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wide;
}
