import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color backgroundStart = Color(0xFF07162D);
  static const Color backgroundEnd = Color(0xFF020A17);
  static const Color card = Color(0xFF102543);
  static const Color cardSoft = Color(0xFF173358);
  static const Color accent = Color(0xFF58B8FF);
  static const Color accentSoft = Color(0xFF87D0FF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB6C7E0);
  static const Color success = Color(0xFF35D59A);
  static const Color danger = Color(0xFFFF6B82);
  static const Color border = Color(0xFF244B79);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[backgroundStart, backgroundEnd],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF13345D), Color(0xFF0C203D)],
  );
}
