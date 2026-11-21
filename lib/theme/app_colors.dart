import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.error,
    required this.chipExcludedBackground,
    required this.achievementUnlockedBackground,
    required this.achievementLockedBackground,
  });

  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Color error;
  final Color chipExcludedBackground;
  final Color achievementUnlockedBackground;
  final Color achievementLockedBackground;

  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>()!;

  static const light = AppColors(
    primary: Color(0xFF2E7D32),
    primaryLight: Color(0xFF4CAF50),
    background: Color(0xFFF7F6F2),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF757575),
    divider: Color(0xFFE0E0E0),
    error: Color(0xFFD32F2F),
    chipExcludedBackground: Color(0xFFFFEBEE),
    achievementUnlockedBackground: Color(0xFFE8F5E9),
    achievementLockedBackground: Color(0xFFEEEEEE),
  );

  static const dark = AppColors(
    primary: Color(0xFF4CAF50),
    primaryLight: Color(0xFF81C784),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFEEEEEE),
    textSecondary: Color(0xFF9E9E9E),
    divider: Color(0xFF2C2C2C),
    error: Color(0xFFEF5350),
    chipExcludedBackground: Color(0xFF3E1E1E),
    achievementUnlockedBackground: Color(0xFF1E3320),
    achievementLockedBackground: Color(0xFF2A2A2A),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    Color? error,
    Color? chipExcludedBackground,
    Color? achievementUnlockedBackground,
    Color? achievementLockedBackground,
  }) =>
      AppColors(
        primary: primary ?? this.primary,
        primaryLight: primaryLight ?? this.primaryLight,
        background: background ?? this.background,
        surface: surface ?? this.surface,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        divider: divider ?? this.divider,
        error: error ?? this.error,
        chipExcludedBackground:
            chipExcludedBackground ?? this.chipExcludedBackground,
        achievementUnlockedBackground:
            achievementUnlockedBackground ?? this.achievementUnlockedBackground,
        achievementLockedBackground:
            achievementLockedBackground ?? this.achievementLockedBackground,
      );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      error: Color.lerp(error, other.error, t)!,
      chipExcludedBackground:
          Color.lerp(chipExcludedBackground, other.chipExcludedBackground, t)!,
      achievementUnlockedBackground: Color.lerp(
          achievementUnlockedBackground, other.achievementUnlockedBackground, t)!,
      achievementLockedBackground: Color.lerp(
          achievementLockedBackground, other.achievementLockedBackground, t)!,
    );
  }
}
