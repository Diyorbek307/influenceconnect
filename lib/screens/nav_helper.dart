import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import 'admin/admin_home.dart';
import 'blogger/blogger_home.dart';
import 'brand/brand_home.dart';
import 'role_selection_screen.dart';

/// Централизованная маршрутизация по ролям, чтобы не дублировать логику.
class AppNav {
  AppNav._();

  /// Экран, соответствующий текущему пользователю.
  static Widget homeForCurrentUser() {
    final user = AppRepository.instance.currentUser;
    if (user == null) return const RoleSelectionScreen();
    if (!user.hasRole) return const RoleSelectionScreen();
    if (user.isAdmin) return const AdminHome();
    if (user.isBrand) return const BrandHome();
    if (user.isBlogger) return const BloggerHome();
    return const RoleSelectionScreen();
  }

  /// Перейти на домашний экран по роли, очистив стек.
  static void goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => homeForCurrentUser()),
      (route) => false,
    );
  }

  /// Выйти из аккаунта и вернуться на экран входа.
  static Future<void> logout(BuildContext context) async {
    await AppRepository.instance.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }
}
