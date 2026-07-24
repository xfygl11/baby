import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_theme.dart';
import '../../core/utils/date_time_utils.dart';
import '../../core/constants/app_enums.dart';

class ThemeBuilder {
  static const double _radiusSm = 8.0;
  static const double _radiusMd = 14.0;
  static const double _radiusLg = 20.0;
  static const double _radiusPill = 999.0;

  static const double _spacingXs = 4.0;
  static const double _spacingSm = 8.0;
  static const double _spacingMd = 12.0;
  static const double _spacingLg = 16.0;
  static const double _spacingXl = 24.0;
  static const double _spacingXxl = 32.0;

  static String stageKeyForAge(DateTime birthDate, {DateTime? now}) {
    final age = DateTimeUtils.calculateAge(birthDate, now: now);
    final months = age.years * 12 + age.months;
    
    if (months < 12) return 'infant';
    if (months < 36) return 'toddler';
    if (months < 72) return 'preschool';
    if (months < 144) return 'school';
    return 'teen';
  }

  static String stageKeyFromMonths(int ageMonths) {
    if (ageMonths < 12) return 'infant';
    if (ageMonths < 36) return 'toddler';
    if (ageMonths < 72) return 'preschool';
    if (ageMonths < 144) return 'school';
    return 'teen';
  }

  static GrowthStage growthStageFromMonths(int ageMonths) {
    if (ageMonths < 12) return GrowthStage.infant;
    if (ageMonths < 36) return GrowthStage.toddler;
    if (ageMonths < 72) return GrowthStage.preschool;
    if (ageMonths < 144) return GrowthStage.school;
    return GrowthStage.teen;
  }

  static AppTheme _buildAppTheme(StageColors stage, bool isDark) {
    // 深色模式下使用更高对比度的文本颜色，确保符合 WCAG AA 标准
    final Color textPrimaryColor = isDark 
        ? const Color(0xFFFAFAF9)  // 更亮的白色，提高对比度
        : AppColors.ink900;
    final Color textSecondaryColor = isDark 
        ? const Color(0xFFD6D3D1)  // 中等亮度的灰色
        : AppColors.ink600;
    final Color textTertiaryColor = isDark 
        ? const Color(0xFFA8A29E)  // 较暗的灰色，但仍保持足够对比度
        : AppColors.ink300;
    
    return AppTheme(
      stageBg: stage.bg,
      stageSurface: stage.surface,
      stageAccent: stage.accent,
      stageAccentLight: stage.accentLight,
      stageAccentDark: stage.accentDark,
      milestoneGold: AppColors.gold,
      success: AppColors.success,
      warning: AppColors.warning,
      danger: AppColors.danger,
      info: AppColors.info,
      textPrimary: textPrimaryColor,
      textSecondary: textSecondaryColor,
      textTertiary: textTertiaryColor,
      onAccent: isDark ? const Color(0xFF1A1A1A) : AppColors.paper,
      paper: isDark ? const Color(0xFF1A1612) : AppColors.paper,
      radiusSm: _radiusSm,
      radiusMd: _radiusMd,
      radiusLg: _radiusLg,
      radiusPill: _radiusPill,
      spacingXs: _spacingXs,
      spacingSm: _spacingSm,
      spacingMd: _spacingMd,
      spacingLg: _spacingLg,
      spacingXl: _spacingXl,
      spacingXxl: _spacingXxl,
    );
  }

  static ThemeData buildTheme({
    required String stageKey,
    required bool isDark,
    ColorScheme? dynamicColorScheme,
    double fontSizeScale = 1.0,
  }) {
    final stage = isDark 
        ? stageThemesDark[stageKey]! 
        : stageThemesLight[stageKey]!;
    final appTheme = _buildAppTheme(stage, isDark);

    final colorScheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: stage.accent,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    final adjustedScheme = colorScheme.copyWith(
      primary: stage.accent,
      onPrimary: appTheme.onAccent,
      surface: stage.surface,
      onSurface: appTheme.textPrimary,
      background: stage.bg,
      onBackground: appTheme.textPrimary,
      secondary: stage.accentLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: adjustedScheme,
      scaffoldBackgroundColor: stage.bg,
      
      extensions: [appTheme],
      
      appBarTheme: AppBarTheme(
        backgroundColor: stage.bg,
        foregroundColor: appTheme.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: appTheme.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      cardTheme: CardTheme(
        color: stage.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          side: BorderSide(
            color: isDark ? const Color(0xFF3D3028) : const Color(0xFFE8E0D8),
            width: 1,
          ),
        ),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: stage.surface,
        selectedItemColor: stage.accent,
        unselectedItemColor: appTheme.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: stage.accent,
        foregroundColor: appTheme.onAccent,
        elevation: 6,
      ),
      
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 40 * fontSizeScale,
          fontWeight: FontWeight.w800,
          color: appTheme.textPrimary,
          letterSpacing: -0.02,
        ),
        titleLarge: TextStyle(
          fontSize: 22 * fontSizeScale,
          fontWeight: FontWeight.w600,
          color: appTheme.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18 * fontSizeScale,
          fontWeight: FontWeight.w600,
          color: appTheme.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16 * fontSizeScale,
          color: appTheme.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 15 * fontSizeScale,
          color: appTheme.textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 13 * fontSizeScale,
          color: appTheme.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 15 * fontSizeScale,
          fontWeight: FontWeight.w500,
          color: appTheme.textPrimary,
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: stage.accent,
          foregroundColor: appTheme.onAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusPill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: stage.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusPill),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: BorderSide(color: stage.accent, width: 1.5),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: stage.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radiusPill),
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: stage.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
          borderSide: BorderSide(color: stage.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: stage.surface,
        selectedColor: stage.accent.withOpacity(0.2),
        labelStyle: TextStyle(color: appTheme.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusPill),
        ),
      ),
      
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF3D3028) : const Color(0xFFE8E0D8),
        thickness: 1,
        space: 1,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: appTheme.textPrimary,
        contentTextStyle: TextStyle(color: appTheme.paper),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
