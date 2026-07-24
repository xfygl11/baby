import 'package:flutter/material.dart';

class AppColors {
  static const Color rose50 = Color(0xFFFFF5F7);
  static const Color rose100 = Color(0xFFFFE4EA);
  static const Color rose300 = Color(0xFFFFB6C9);
  static const Color rose500 = Color(0xFFF472A3);
  static const Color rose700 = Color(0xFFC0397A);
  
  static const Color sky50 = Color(0xFFF0F8FF);
  static const Color sky300 = Color(0xFF7DD3FC);
  static const Color sky500 = Color(0xFF38BDF8);
  
  static const Color moss50 = Color(0xFFF0FFF0);
  static const Color moss500 = Color(0xFF4CAF50);
  
  static const Color amber500 = Color(0xFFFF9800);
  static const Color crimson = Color(0xFFE53935);
  static const Color gold = Color(0xFFD4AF37);
  
  static const Color ink900 = Color(0xFF1F1B16);
  static const Color ink600 = Color(0xFF5C534A);
  static const Color ink300 = Color(0xFFB8AFA5);
  static const Color paper = Color(0xFFFFFBF5);
  
  static const Color success = moss500;
  static const Color warning = amber500;
  static const Color danger = crimson;
  static const Color info = sky500;
  static const Color milestone = gold;
}

class StageColors {
  final Color bg;
  final Color surface;
  final Color accent;
  final Color accentLight;
  final Color accentDark;
  
  const StageColors({
    required this.bg,
    required this.surface,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
  });
}

final Map<String, StageColors> stageThemesLight = {
  'infant': StageColors(
    bg: AppColors.rose50,
    surface: AppColors.rose100,
    accent: AppColors.rose500,
    accentLight: AppColors.rose300,
    accentDark: AppColors.rose700,
  ),
  'toddler': StageColors(
    bg: AppColors.sky50,
    surface: const Color(0xFFE0F2FE),
    accent: AppColors.sky500,
    accentLight: AppColors.sky300,
    accentDark: const Color(0xFF0284C7),
  ),
  'preschool': StageColors(
    bg: AppColors.moss50,
    surface: const Color(0xFFDCFCE7),
    accent: AppColors.moss500,
    accentLight: const Color(0xFF86EFAC),
    accentDark: const Color(0xFF15803D),
  ),
  'school': StageColors(
    bg: const Color(0xFFF8F0FF),
    surface: const Color(0xFFEDE0FF),
    accent: const Color(0xFF9C7AE0),
    accentLight: const Color(0xFFC4B5FD),
    accentDark: const Color(0xFF7C3AED),
  ),
  'teen': StageColors(
    bg: const Color(0xFFFFF8E7),
    surface: const Color(0xFFFFEFCC),
    accent: AppColors.amber500,
    accentLight: const Color(0xFFFCD34D),
    accentDark: const Color(0xFFD97706),
  ),
};

final Map<String, StageColors> stageThemesDark = {
  'infant': StageColors(
    bg: const Color(0xFF2A1F24),
    surface: const Color(0xFF3D2B33),
    accent: AppColors.rose300,
    accentLight: AppColors.rose100,
    accentDark: AppColors.rose500,
  ),
  'toddler': StageColors(
    bg: const Color(0xFF0C1929),
    surface: const Color(0xFF1E3A5F),
    accent: AppColors.sky300,
    accentLight: AppColors.sky500,
    accentDark: AppColors.sky500,
  ),
  'preschool': StageColors(
    bg: const Color(0xFF142814),
    surface: const Color(0xFF1E3D1E),
    accent: const Color(0xFF86EFAC),
    accentLight: const Color(0xFFBBF7D0),
    accentDark: AppColors.moss500,
  ),
  'school': StageColors(
    bg: const Color(0xFF1F1A2E),
    surface: const Color(0xFF2D2640),
    accent: const Color(0xFFC4B5FD),
    accentLight: const Color(0xFFDDD6FE),
    accentDark: const Color(0xFF9C7AE0),
  ),
  'teen': StageColors(
    bg: const Color(0xFF2A2416),
    surface: const Color(0xFF3D3520),
    accent: const Color(0xFFFCD34D),
    accentLight: const Color(0xFFFDE68A),
    accentDark: AppColors.amber500,
  ),
};
