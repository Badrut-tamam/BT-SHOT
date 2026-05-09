import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color background = Color(0xFF0F0C29);
  static const Color backgroundEnd = Color(0xFF302B63);
  static const Color backgroundAccent = Color(0xFF24243E);

  // Neon Accents
  static const Color neonBlue = Color(0xFF00D2FF);
  static const Color neonPurple = Color(0xFF9D50BB);
  static const Color neonPink = Color(0xFFFF00CC);
  
  // Glass Effects
  static Color glassBackground = Colors.white.withOpacity(0.1);
  static Color glassBorder = Colors.white.withOpacity(0.2);
  static Color glassHighlight = Colors.white.withOpacity(0.3);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonBlue, neonPurple],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundAccent, background],
  );
}
