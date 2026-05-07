import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 coherent theme. Brand [primaryColor] / [secondaryColor] / [accentColor]
/// stay as public constants so existing screens keep working; [lightTheme]/[darkTheme]
/// use [ColorScheme.fromSeed] for tonal surfaces (M3).
class AppTheme {
  AppTheme._();

  // Brand (logo-matched)
  // Blue taken from logo dominant tone; orange from logo highlight.
  static const Color primaryColor = Color(0xFF2E8BB5);
  static const Color secondaryColor = Color(0xFF1D5B7A);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFB8C00);
  static const Color infoColor = Color(0xFF4A90E2);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  static const double _radius = 12;
  static const BorderRadius _borderRadius =
      BorderRadius.all(Radius.circular(_radius));

  static ColorScheme _lightColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      onTertiary: Colors.white,
      error: errorColor,
      onError: Colors.white,
    );
  }

  static ColorScheme _darkColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      secondary: secondaryColor,
      onSecondary: Colors.white,
      tertiary: accentColor,
      onTertiary: Colors.black87,
      error: errorColor,
      onError: Colors.white,
    );
  }

  static ThemeData get lightTheme {
    final cs = _lightColorScheme();
    final baseText = ThemeData(useMaterial3: true, colorScheme: cs).textTheme;
    final textTheme = GoogleFonts.latoTextTheme(baseText).apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      primaryColor: cs.primary,
      scaffoldBackgroundColor: cs.surface,
      fontFamily: GoogleFonts.lato().fontFamily,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: cs.onSurfaceVariant),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.surfaceTint,
        iconTheme: IconThemeData(color: cs.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceContainerLow,
        surfaceTintColor: cs.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        clipBehavior: Clip.antiAlias,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          side: BorderSide(color: cs.primary, width: 1.5),
          foregroundColor: cs.primary,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: cs.primary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surfaceContainer,
        indicatorColor: cs.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        dividerColor: cs.outlineVariant,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        unselectedLabelStyle:
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.onPrimary
              : cs.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.primary
              : cs.surfaceContainerHighest,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.primary
              : cs.surfaceContainerHighest,
        ),
        checkColor: WidgetStatePropertyAll(cs.onPrimary),
        side: BorderSide(color: cs.outlineVariant, width: 1.5),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        deleteIconColor: cs.onSurfaceVariant,
        disabledColor: cs.onSurface.withValues(alpha: 0.12),
        selectedColor: cs.secondaryContainer,
        secondarySelectedColor: cs.tertiaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge,
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: cs.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: cs.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        selectedColor: cs.primary,
        selectedTileColor: cs.primaryContainer.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: cs.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.surfaceContainerHighest,
        circularTrackColor: cs.surfaceContainerHighest,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    final cs = _darkColorScheme();
    final baseText = ThemeData(useMaterial3: true, colorScheme: cs).textTheme;
    final textTheme = GoogleFonts.latoTextTheme(baseText).apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      primaryColor: cs.primary,
      scaffoldBackgroundColor: cs.surface,
      fontFamily: GoogleFonts.lato().fontFamily,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: cs.onSurfaceVariant),

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        surfaceTintColor: cs.surfaceTint,
        iconTheme: IconThemeData(color: cs.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceContainerLow,
        surfaceTintColor: cs.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        clipBehavior: Clip.antiAlias,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          side: BorderSide(color: cs.primary, width: 1.5),
          foregroundColor: cs.primary,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: cs.primary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.75),
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: cs.onSurfaceVariant,
        suffixIconColor: cs.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _borderRadius,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surfaceContainer,
        indicatorColor: cs.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: cs.primary,
        unselectedLabelColor: cs.onSurfaceVariant,
        indicatorColor: cs.primary,
        dividerColor: cs.outlineVariant,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        unselectedLabelStyle:
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.onPrimary
              : cs.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.primary
              : cs.surfaceContainerHighest,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cs.primary
              : cs.surfaceContainerHighest,
        ),
        checkColor: WidgetStatePropertyAll(cs.onPrimary),
        side: BorderSide(color: cs.outlineVariant, width: 1.5),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        deleteIconColor: cs.onSurfaceVariant,
        disabledColor: cs.onSurface.withValues(alpha: 0.12),
        selectedColor: cs.secondaryContainer,
        secondarySelectedColor: cs.tertiaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge,
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: cs.surfaceTint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surfaceContainerHigh,
        surfaceTintColor: cs.surfaceTint,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: cs.onSurfaceVariant,
        textColor: cs.onSurface,
        selectedColor: cs.primary,
        selectedTileColor: cs.primaryContainer.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: cs.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: _borderRadius),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.surfaceContainerHighest,
        circularTrackColor: cs.surfaceContainerHighest,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
