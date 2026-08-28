import 'package:flutter/material.dart';

/// Катушки на складе. `silk` рисуется с глянцевым бликом.
@immutable
class FilamentColor {
  const FilamentColor(this.name, this.color, {this.silk = false});

  final String name;
  final Color color;
  final bool silk;
}

const kFilamentColors = <FilamentColor>[
  FilamentColor('Graphite', Color(0xFF16181C)),
  FilamentColor('Obsidian', Color(0xFF08090C)),
  FilamentColor('Steel', Color(0xFF3B4353)),
  FilamentColor('Silver', Color(0xFFC3CEE6)),
  FilamentColor('Arctic', Color(0xFFEEF3FA)),
  FilamentColor('Sand', Color(0xFFE2CFA8)),
  FilamentColor('Ember', Color(0xFFFF4A1C)),
  FilamentColor('Sunburst', Color(0xFFFF7A18)),
  FilamentColor('Amber', Color(0xFFFFB020)),
  FilamentColor('Gold Silk', Color(0xFFE0B23C), silk: true),
  FilamentColor('Magenta', Color(0xFFFF2D8F)),
  FilamentColor('Blush', Color(0xFFFF7FB6)),
  FilamentColor('Ruby', Color(0xFFE30F3E)),
  FilamentColor('Wine', Color(0xFF6E1030)),
  FilamentColor('Plasma', Color(0xFFA855F7)),
  FilamentColor('Indigo', Color(0xFF3B44FF)),
  FilamentColor('Azure', Color(0xFF1E7BFF)),
  FilamentColor('Cyan', Color(0xFF2BB8FF)),
  FilamentColor('Ice', Color(0xFFA9E8FF)),
  FilamentColor('Teal', Color(0xFF00D9C4)),
  FilamentColor('Emerald', Color(0xFF16F2AE)),
  FilamentColor('Lime', Color(0xFFB6FF2E)),
  FilamentColor('Moss', Color(0xFF2F7D46)),
  FilamentColor('Copper Silk', Color(0xFFC4703A), silk: true),
];

String colorName(Color c) {
  for (final f in kFilamentColors) {
    if (f.color.toARGB32() == c.toARGB32()) return f.name;
  }
  return 'Custom';
}
