import 'package:flutter/material.dart';

import 'case_part.dart';
import 'filament.dart';

/// Готовая схема покраски: цвет и материал каждой детали плюс акцент,
/// в который перекрашивается вся страница.
@immutable
class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.tag,
    required this.colors,
    required this.filaments,
    required this.accent,
    required this.accentAlt,
  });

  final String id;
  final String name;
  final String tag;
  final Map<PartId, Color> colors;
  final Map<PartId, FilamentId> filaments;
  final Color accent;
  final Color accentAlt;
}

const kPresets = <Preset>[
  Preset(
    id: 'ember',
    name: 'Ember Cyan',
    tag: 'Хит фермы',
    colors: {
      PartId.front: Color(0xFF16181C),
      PartId.side: Color(0xFF2BB8FF),
      PartId.top: Color(0xFF16181C),
      PartId.feet: Color(0xFFFF4A1C),
      PartId.badge: Color(0xFFFF4A1C),
      PartId.comb: Color(0xFF16F2AE),
    },
    filaments: {
      PartId.front: FilamentId.plaCf,
      PartId.side: FilamentId.asa,
      PartId.top: FilamentId.plaCf,
      PartId.feet: FilamentId.petg,
      PartId.badge: FilamentId.silk,
      PartId.comb: FilamentId.petg,
    },
    accent: Color(0xFFFF4A1C),
    accentAlt: Color(0xFFFF2D8F),
  ),
  Preset(
    id: 'nova',
    name: 'Nova Magenta',
    tag: 'Ночной билд',
    colors: {
      PartId.front: Color(0xFF08090C),
      PartId.side: Color(0xFFFF2D8F),
      PartId.top: Color(0xFF08090C),
      PartId.feet: Color(0xFFFF2D8F),
      PartId.badge: Color(0xFFFF7FB6),
      PartId.comb: Color(0xFFA855F7),
    },
    filaments: {
      PartId.front: FilamentId.plaCf,
      PartId.side: FilamentId.asa,
      PartId.top: FilamentId.plaCf,
      PartId.feet: FilamentId.petg,
      PartId.badge: FilamentId.silk,
      PartId.comb: FilamentId.petg,
    },
    accent: Color(0xFFFF2D8F),
    accentAlt: Color(0xFFA855F7),
  ),
  Preset(
    id: 'arctic',
    name: 'Arctic PETG',
    tag: 'Светлый стол',
    colors: {
      PartId.front: Color(0xFFEEF3FA),
      PartId.side: Color(0xFFA9E8FF),
      PartId.top: Color(0xFFEEF3FA),
      PartId.feet: Color(0xFF2BB8FF),
      PartId.badge: Color(0xFF3B4353),
      PartId.comb: Color(0xFF1E7BFF),
    },
    filaments: {
      PartId.front: FilamentId.petg,
      PartId.side: FilamentId.asa,
      PartId.top: FilamentId.petg,
      PartId.feet: FilamentId.petg,
      PartId.badge: FilamentId.silk,
      PartId.comb: FilamentId.petg,
    },
    accent: Color(0xFF2BB8FF),
    accentAlt: Color(0xFF16F2AE),
  ),
  Preset(
    id: 'toxic',
    name: 'Toxic Lime',
    tag: 'Кислота',
    colors: {
      PartId.front: Color(0xFF16181C),
      PartId.side: Color(0xFFB6FF2E),
      PartId.top: Color(0xFF16181C),
      PartId.feet: Color(0xFFB6FF2E),
      PartId.badge: Color(0xFF08090C),
      PartId.comb: Color(0xFFB6FF2E),
    },
    filaments: {
      PartId.front: FilamentId.plaCf,
      PartId.side: FilamentId.asa,
      PartId.top: FilamentId.plaCf,
      PartId.feet: FilamentId.petg,
      PartId.badge: FilamentId.pla,
      PartId.comb: FilamentId.petg,
    },
    accent: Color(0xFFB6FF2E),
    accentAlt: Color(0xFF16F2AE),
  ),
  Preset(
    id: 'carbon',
    name: 'Carbon Stealth',
    tag: 'Матовый',
    colors: {
      PartId.front: Color(0xFF08090C),
      PartId.side: Color(0xFF3B4353),
      PartId.top: Color(0xFF08090C),
      PartId.feet: Color(0xFF3B4353),
      PartId.badge: Color(0xFFC3CEE6),
      PartId.comb: Color(0xFF16181C),
    },
    filaments: {
      PartId.front: FilamentId.plaCf,
      PartId.side: FilamentId.asa,
      PartId.top: FilamentId.plaCf,
      PartId.feet: FilamentId.plaCf,
      PartId.badge: FilamentId.silk,
      PartId.comb: FilamentId.petg,
    },
    accent: Color(0xFFC3CEE6),
    accentAlt: Color(0xFF7E8CAC),
  ),
  Preset(
    id: 'sunset',
    name: 'Sunset Silk',
    tag: 'Глянец',
    colors: {
      PartId.front: Color(0xFFFF7A18),
      PartId.side: Color(0xFFFFB020),
      PartId.top: Color(0xFFFF2D8F),
      PartId.feet: Color(0xFFE0B23C),
      PartId.badge: Color(0xFF08090C),
      PartId.comb: Color(0xFFFF2D8F),
    },
    filaments: {
      PartId.front: FilamentId.silk,
      PartId.side: FilamentId.asa,
      PartId.top: FilamentId.silk,
      PartId.feet: FilamentId.silk,
      PartId.badge: FilamentId.pla,
      PartId.comb: FilamentId.silk,
    },
    accent: Color(0xFFFF7A18),
    accentAlt: Color(0xFFFF2D8F),
  ),
];

Preset presetOf(String id) => kPresets.firstWhere((p) => p.id == id);
