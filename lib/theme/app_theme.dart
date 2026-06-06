import 'package:flutter/material.dart';

class AppTheme {
  // Core palette
  static const Color background = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF17171A);
  static const Color surfaceElevated = Color(0xFF1E1E22);
  static const Color border = Color(0xFF2A2A30);

  static const Color focusAccent = Color(0xFFE8845C);
  static const Color focusGlow = Color(0x40E8845C);
  static const Color shortBreakAccent = Color(0xFF5CB8B2);
  static const Color shortBreakGlow = Color(0x405CB8B2);
  static const Color longBreakAccent = Color(0xFF7B8FD4);
  static const Color longBreakGlow = Color(0x407B8FD4);

  static const Color textPrimary = Color(0xFFF0EEE8);
  static const Color textSecondary = Color(0xFF8A8880);
  static const Color textTertiary = Color(0xFF4A4A50);

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        fontFamily: 'monospace',
        colorScheme: const ColorScheme.dark(
          background: background,
          surface: surface,
          primary: focusAccent,
        ),
        useMaterial3: true,
      );
}
