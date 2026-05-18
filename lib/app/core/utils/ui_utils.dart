import 'package:flutter/material.dart';

class UIUtils {
  UIUtils._();

  /// Returns a glossy decoration with a subtle top-light highlight and gradient.
  static BoxDecoration glossyDecoration({
    required Color baseColor,
    double borderRadius = 20,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withOpacity(0.9),
          baseColor,
          baseColor.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      boxShadow: [
        // Main shadow
        BoxShadow(
          color: baseColor.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
        // Inner highlight (Glossy effect)
        BoxShadow(
          color: Colors.white.withOpacity(0.2),
          blurRadius: 0,
          offset: const Offset(1, 1),
          spreadRadius: -1,
        ),
      ],
      border: showBorder
          ? Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            )
          : null,
    );
  }

  /// Returns a glassmorphic decoration.
  static BoxDecoration glassDecoration({
    double borderRadius = 20,
    Color? color,
  }) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(0.15),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
    );
  }

  /// Returns a 3D neumorphic-style decoration for buttons.
  static BoxDecoration threeDDecoration({
    required Color color,
    double borderRadius = 12,
    bool isPressed = false,
  }) {
    if (isPressed) {
      return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      );
    }

    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withOpacity(0.1),
          Colors.transparent,
        ],
      ),
      boxShadow: [
        // Bottom depth
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 0,
          offset: const Offset(0, 4),
        ),
        // Side depth
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// Returns a decoration with a pulsing glow effect for primary buttons.
  static BoxDecoration animatedPulseDecoration({
    required Color color,
    required double pulseValue, // 0.0 to 1.0
    double borderRadius = 16,
  }) {
    return glossyDecoration(
      baseColor: color,
      borderRadius: borderRadius,
    ).copyWith(
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3 * pulseValue),
          blurRadius: 15 + (10 * pulseValue),
          spreadRadius: 2 * pulseValue,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.2),
          blurRadius: 0,
          offset: const Offset(1, 1),
          spreadRadius: -1,
        ),
      ],
    );
  }

  /// Returns a complex mesh gradient decoration.
  static BoxDecoration meshGradientDecoration({
    required List<Color> colors,
    double borderRadius = 0,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
        stops: const [0.0, 0.4, 0.7, 1.0],
      ),
    );
  }

  /// Returns a glassmorphic input decoration for text fields.
  static InputDecoration glassInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Color? baseColor,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: (baseColor ?? const Color(0xFF64748B)).withOpacity(0.8), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: baseColor ?? const Color(0xFF8B5CF6), size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
      ),
    );
  }
}

extension InsetShadow on BoxShadow {
  bool get inset => true; // Just a placeholder for logic if needed
}
