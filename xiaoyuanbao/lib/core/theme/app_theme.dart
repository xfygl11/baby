import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme extends ThemeExtension<AppTheme> {
  final Color stageBg;
  final Color stageSurface;
  final Color stageAccent;
  final Color stageAccentLight;
  final Color stageAccentDark;
  final Color milestoneGold;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color onAccent;
  final Color paper;
  
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusPill;
  
  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double spacingXxl;

  const AppTheme({
    required this.stageBg,
    required this.stageSurface,
    required this.stageAccent,
    required this.stageAccentLight,
    required this.stageAccentDark,
    required this.milestoneGold,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.onAccent,
    required this.paper,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusPill,
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.spacingXxl,
  });

  @override
  ThemeExtension<AppTheme> copyWith({
    Color? stageBg,
    Color? stageSurface,
    Color? stageAccent,
    Color? stageAccentLight,
    Color? stageAccentDark,
    Color? milestoneGold,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? onAccent,
    Color? paper,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusPill,
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? spacingXxl,
  }) {
    return AppTheme(
      stageBg: stageBg ?? this.stageBg,
      stageSurface: stageSurface ?? this.stageSurface,
      stageAccent: stageAccent ?? this.stageAccent,
      stageAccentLight: stageAccentLight ?? this.stageAccentLight,
      stageAccentDark: stageAccentDark ?? this.stageAccentDark,
      milestoneGold: milestoneGold ?? this.milestoneGold,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      onAccent: onAccent ?? this.onAccent,
      paper: paper ?? this.paper,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusPill: radiusPill ?? this.radiusPill,
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacingXxl: spacingXxl ?? this.spacingXxl,
    );
  }

  @override
  ThemeExtension<AppTheme> lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    return AppTheme(
      stageBg: Color.lerp(stageBg, other.stageBg, t)!,
      stageSurface: Color.lerp(stageSurface, other.stageSurface, t)!,
      stageAccent: Color.lerp(stageAccent, other.stageAccent, t)!,
      stageAccentLight: Color.lerp(stageAccentLight, other.stageAccentLight, t)!,
      stageAccentDark: Color.lerp(stageAccentDark, other.stageAccentDark, t)!,
      milestoneGold: Color.lerp(milestoneGold, other.milestoneGold, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      radiusSm: radiusSm,
      radiusMd: radiusMd,
      radiusLg: radiusLg,
      radiusPill: radiusPill,
      spacingXs: spacingXs,
      spacingSm: spacingSm,
      spacingMd: spacingMd,
      spacingLg: spacingLg,
      spacingXl: spacingXl,
      spacingXxl: spacingXxl,
    );
  }

  static AppTheme of(BuildContext context) {
    return Theme.of(context).extension<AppTheme>()!;
  }
}
