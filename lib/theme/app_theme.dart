import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Vivid Kinetic - a bright, high-energy "Kinetic Minimalism" design system.
/// Pristine white base, electric blue accents, energetic orange triggers.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF003EC7);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF0052FF);
  static const onPrimaryContainer = Color(0xFFDFE3FF);
  static const primaryFixedDim = Color(0xFFB7C4FF);

  static const secondary = Color(0xFFA33800);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFCD4800);
  static const onSecondaryContainer = Color(0xFFFFFBFF);

  static const tertiary = Color(0xFF005A3C);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF007550);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const surface = Color(0xFFFAF8FF);
  static const onSurface = Color(0xFF131B2E);
  static const onSurfaceVariant = Color(0xFF434656);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F3FF);
  static const surfaceContainer = Color(0xFFEAEDFF);
  static const surfaceContainerHigh = Color(0xFFE2E7FF);
  static const surfaceContainerHighest = Color(0xFFDAE2FD);
  static const surfaceVariant = Color(0xFFDAE2FD);

  static const outline = Color(0xFF737688);
  static const outlineVariant = Color(0xFFC3C5D9);
  static const surfaceTint = Color(0xFF004CED);
  static const inverseSurface = Color(0xFF283044);
  static const onInverseSurface = Color(0xFFEEF0FF);
  static const inversePrimary = Color(0xFFB7C4FF);

  /// Light gray fill used by input fields and progress tracks.
  static const fieldFill = Color(0xFFF1F5F9);
}

/// Soft, diffused ambient shadow with a slight blue tint that ties into the
/// primary brand color (Elevation: low-opacity, large blur).
const List<BoxShadow> kAmbientShadow = [
  BoxShadow(
    color: Color(0x140052FF), // ~8% blue
    blurRadius: 30,
    offset: Offset(0, 20),
    spreadRadius: -10,
  ),
];

ColorScheme get _kineticScheme => const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiary,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      surfaceTint: AppColors.surfaceTint,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.onInverseSurface,
      inversePrimary: AppColors.inversePrimary,
    );

ThemeData buildKineticTheme() {
  final scheme = _kineticScheme;

  // Dual-font strategy: Montserrat (geometric, athletic) for headlines,
  // Hanken Grotesk (technical clarity) for body and UI labels.
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  final headline = GoogleFonts.montserrat;
  final body = GoogleFonts.hankenGrotesk;

  final textTheme = base.textTheme.copyWith(
    displayLarge: headline(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.2,
        color: scheme.onSurface),
    headlineLarge: headline(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.32,
        height: 1.25,
        color: scheme.onSurface),
    headlineMedium: headline(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
        color: scheme.onSurface),
    headlineSmall: headline(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: scheme.onSurface),
    titleLarge: headline(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: scheme.onSurface),
    titleMedium: body(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: scheme.onSurface),
    bodyLarge: body(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.56,
        color: scheme.onSurface),
    bodyMedium: body(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: scheme.onSurface),
    bodySmall: body(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: scheme.onSurfaceVariant),
    labelLarge: body(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.7,
        height: 1.43),
    labelMedium: body(
        fontSize: 12, fontWeight: FontWeight.w500, height: 1.33),
  );

  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: headline(
          fontSize: 20, fontWeight: FontWeight.w700, color: scheme.primary),
      iconTheme: IconThemeData(color: scheme.primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldFill,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: body(color: scheme.onSurfaceVariant),
      floatingLabelStyle: body(color: scheme.primary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        textStyle: headline(fontSize: 16, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        textStyle: body(fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999)),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.secondaryContainer, // energetic orange
      inactiveTrackColor: AppColors.fieldFill,
      thumbColor: AppColors.secondaryContainer,
      overlayColor: AppColors.secondaryContainer.withOpacity(0.12),
      trackHeight: 6,
    ),
    dividerTheme: const DividerThemeData(
        color: AppColors.fieldFill, thickness: 1, space: 1),
  );
}
