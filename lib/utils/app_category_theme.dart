import 'package:flutter/material.dart';
import 'package:wellbeing_app/utils/enums.dart';

class AppCategoryTheme {
  AppCategoryTheme._();

  static const Map<AppCategory, _CategoryStyle> _styles = {
    AppCategory.game: _CategoryStyle(
      color: Color(0xFFD45F5F),
      lightColor: Color(0xFFFBEDED),
      icon: Icons.sports_esports_rounded,
    ),

    AppCategory.entertainment: _CategoryStyle(
      color: Color(0xFF4FA097),
      lightColor: Color(0xFFE8F5F3),
      icon: Icons.movie_rounded,
    ),

    AppCategory.productivity: _CategoryStyle(
      color: Color(0xFF5E78A6),
      lightColor: Color(0xFFEDF2FB),
      icon: Icons.checklist_rounded,
    ),

    AppCategory.social: _CategoryStyle(
      color: Color(0xFFB08A57),
      lightColor: Color(0xFFF7F1E8),
      icon: Icons.people_rounded,
    ),

    AppCategory.education: _CategoryStyle(
      color: Color(0xFF8A68B8),
      lightColor: Color(0xFFF2ECFA),
      icon: Icons.school_rounded,
    ),

    AppCategory.other: _CategoryStyle(
      color: Color(0xFF7EA05E),
      lightColor: Color(0xFFF1F7EB),
      icon: Icons.apps_rounded,
    ),

    AppCategory.system: _CategoryStyle(
      color: Color(0xFF7A8191),
      lightColor: Color(0xFFF4F5F7),
      icon: Icons.settings_rounded,
    ),

    AppCategory.development: _CategoryStyle(
      color: Color(0xFFB0677E),
      lightColor: Color(0xFFF8EDF1),
      icon: Icons.code_rounded,
    ),
  };

  static Color color(AppCategory category) =>
      _styles[category]?.color ?? const Color(0xFF7A8191);

  static Color lightColor(AppCategory category) =>
      _styles[category]?.lightColor ?? const Color(0xFFF4F5F7);

  static Color headerFill(AppCategory category) =>
      color(category).withAlpha(24);

  static IconData icon(AppCategory category) =>
      _styles[category]?.icon ?? Icons.apps_rounded;
}

class _CategoryStyle {
  final Color color;
  final Color lightColor;
  final IconData icon;
  const _CategoryStyle({
    required this.color,
    required this.lightColor,
    required this.icon,
  });
}