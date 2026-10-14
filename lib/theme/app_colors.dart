import 'package:flutter/material.dart';

/// Фирменная палитра InfluenceConnect.
class AppColors {
  AppColors._();

  // Бренд
  static const Color primary = Color(0xFF0066FF);
  static const Color secondary = Color(0xFF7B2CBF);
  static const Color accent = Color(0xFF00C2A8);

  // Семантика
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color like = Color(0xFF22C55E);
  static const Color dislike = Color(0xFFEF4444);
  static const Color save = Color(0xFF0066FF);

  // Светлая тема
  static const Color lightBg = Color(0xFFF6F7FB);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Тёмная тема
  static const Color darkBg = Color(0xFF0B1020);
  static const Color darkSurface = Color(0xFF151B2E);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF26304A);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  /// Стабильный цвет для роли.
  static Color role(String role) {
    switch (role) {
      case 'brand':
        return primary;
      case 'blogger':
        return secondary;
      case 'admin':
        return warning;
      default:
        return lightTextMuted;
    }
  }
}
