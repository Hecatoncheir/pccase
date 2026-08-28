import 'package:flutter/foundation.dart';

/// Печатные детали набора. Порядок — как в конструкторе.
enum PartId { front, side, top, feet, badge, comb }

@immutable
class CasePart {
  const CasePart({required this.id, required this.name, required this.grams});

  final PartId id;
  final String name;

  /// Масса пластика на деталь. Демонстрационные значения —
  /// заменить реальными после обмера модели ModCase Hyper.
  final int grams;
}

const kParts = <CasePart>[
  CasePart(id: PartId.front, name: 'Фронтальная сетка', grams: 214),
  CasePart(id: PartId.side, name: 'Боковое окно', grams: 168),
  CasePart(id: PartId.top, name: 'Верхняя крышка', grams: 142),
  CasePart(id: PartId.feet, name: 'Ножки, 4 шт', grams: 52),
  CasePart(id: PartId.badge, name: 'Шильд', grams: 14),
  CasePart(id: PartId.comb, name: 'Кабель-гребёнка', grams: 26),
];

CasePart partOf(PartId id) => kParts.firstWhere((p) => p.id == id);
