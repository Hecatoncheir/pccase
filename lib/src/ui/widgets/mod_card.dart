import 'package:flutter/material.dart';

import '../../theme/mod_colors.dart';

/// Карточка на общем фоне панели — база для материалов и каталога.
class ModCard extends StatelessWidget {
  const ModCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final c = context.mod;
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.panel, c.panel.withValues(alpha: 0.4)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.lineSoft),
      ),
      child: child,
    );
  }
}
