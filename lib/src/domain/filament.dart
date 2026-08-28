import 'package:flutter/foundation.dart';

enum FilamentId { pla, petg, asa, silk, plaCf }

@immutable
class FilamentMeter {
  const FilamentMeter(this.label, this.value);
  final String label;
  final int value;
}

@immutable
class Filament {
  const Filament({
    required this.id,
    required this.label,
    required this.tempLabel,
    required this.pricePerGram,
    required this.hoursPerGram,
    required this.note,
    required this.meters,
  });

  final FilamentId id;
  final String label;
  final String tempLabel;
  final double pricePerGram;
  final double hoursPerGram;
  final String note;
  final List<FilamentMeter> meters;
}

const kFilaments = <FilamentId, Filament>{
  FilamentId.pla: Filament(
    id: FilamentId.pla,
    label: 'PLA',
    tempLabel: '195–225°C',
    pricePerGram: 2.4,
    hoursPerGram: 0.105,
    note: 'Базовый пластик: максимум цветов и идеальная геометрия. '
        'Не любит прямое солнце и жару в закрытой машине.',
    meters: [
      FilamentMeter('жёсткость', 62),
      FilamentMeter('термостойкость', 24),
      FilamentMeter('внешний вид', 78),
      FilamentMeter('цена', 18),
    ],
  ),
  FilamentId.petg: Filament(
    id: FilamentId.petg,
    label: 'PETG',
    tempLabel: '230–250°C',
    pricePerGram: 3.2,
    hoursPerGram: 0.118,
    note: 'Вязкий и живучий: держит удар и нагрев, прощает перетянутый винт. '
        'Мелкая деталь чуть мягче, чем у PLA.',
    meters: [
      FilamentMeter('жёсткость', 70),
      FilamentMeter('термостойкость', 58),
      FilamentMeter('внешний вид', 58),
      FilamentMeter('цена', 34),
    ],
  ),
  FilamentId.asa: Filament(
    id: FilamentId.asa,
    label: 'ASA',
    tempLabel: '250–270°C',
    pricePerGram: 4.4,
    hoursPerGram: 0.126,
    note: 'Для солнца и жары: не желтеет и не ведёт со временем. '
        'Печатается в закрытой камере — отсюда цена и срок.',
    meters: [
      FilamentMeter('жёсткость', 76),
      FilamentMeter('термостойкость', 88),
      FilamentMeter('внешний вид', 64),
      FilamentMeter('цена', 58),
    ],
  ),
  FilamentId.silk: Filament(
    id: FilamentId.silk,
    label: 'SILK',
    tempLabel: '205–230°C',
    pricePerGram: 3.6,
    hoursPerGram: 0.112,
    note: 'Глянец под металл: панель читается как крашеный алюминий. '
        'Царапается легче матовых пластиков.',
    meters: [
      FilamentMeter('жёсткость', 58),
      FilamentMeter('термостойкость', 24),
      FilamentMeter('внешний вид', 100),
      FilamentMeter('цена', 44),
    ],
  ),
  FilamentId.plaCf: Filament(
    id: FilamentId.plaCf,
    label: 'PLA-CF',
    tempLabel: '220–240°C',
    pricePerGram: 7.1,
    hoursPerGram: 0.132,
    note: 'Матовый угольный: самый жёсткий в наборе, полностью прячет слои. '
        'Идеален для сетки и несущих панелей.',
    meters: [
      FilamentMeter('жёсткость', 100),
      FilamentMeter('термостойкость', 44),
      FilamentMeter('внешний вид', 92),
      FilamentMeter('цена', 96),
    ],
  ),
};

Filament filamentOf(FilamentId id) => kFilaments[id]!;
