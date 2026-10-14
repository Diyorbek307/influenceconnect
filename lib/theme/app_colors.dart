import 'package:flutter/material.dart';

/// Яркая «сочная» палитра InfluenceConnect.
class AppColors {
  AppColors._();

  // Бренд — насыщенные розовый → фиолетовый + тёплый оранжевый акцент
  static const Color primary = Color(0xFFFF2D74); // яркий розовый
  static const Color secondary = Color(0xFF8B3DFF); // фиолетовый
  static const Color accent = Color(0xFFFF8A3D); // оранжевый

  // Семантика
  static const Color success = Color(0xFF17C964);
  static const Color danger = Color(0xFFFF4D5E);
  static const Color warning = Color(0xFFFFB020);
  static const Color like = Color(0xFF17C964);
  static const Color dislike = Color(0xFFFF4D5E);
  static const Color save = Color(0xFF8B3DFF);

  // Светлая тема
  static const Color lightBg = Color(0xFFFFF5FA); // лёгкий розовый оттенок
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1A1030);
  static const Color lightTextMuted = Color(0xFF8A7F99);
  static const Color lightBorder = Color(0xFFF0E4EE);

  // Тёмная тема
  static const Color darkBg = Color(0xFF130A1F);
  static const Color darkSurface = Color(0xFF1E1230);
  static const Color darkText = Color(0xFFF8F2FF);
  static const Color darkTextMuted = Color(0xFFB4A3C8);
  static const Color darkBorder = Color(0xFF32224A);

  /// Главный «сочный» градиент: розовый → фиолетовый.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF2D74), Color(0xFFB02DFF)],
  );

  /// Тёплый градиент-акцент: розовый → оранжевый.
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF2D74), Color(0xFFFF8A3D)],
  );

  /// Полный сочный градиент: розовый → оранжевый → фиолетовый.
  static const LinearGradient vividGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF2D74), Color(0xFFFF6A4D), Color(0xFF8B3DFF)],
  );

  /// Стабильный цвет для роли.
  static Color role(String role) {
    switch (role) {
      case 'brand':
        return primary;
      case 'blogger':
        return secondary;
      case 'admin':
        return accent;
      default:
        return lightTextMuted;
    }
  }
}
