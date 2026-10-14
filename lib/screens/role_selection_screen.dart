import 'package:flutter/material.dart';

import '../data/app_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'auth/login_screen.dart';
import 'nav_helper.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _loading = false;

  Future<void> _select(String role) async {
    setState(() => _loading = true);
    try {
      await AppRepository.instance.enterAsRole(role);
      if (!mounted) return;
      AppNav.goHome(context);
    } on AppException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Кто вы?', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text('Выберите роль — так мы покажем нужные функции.',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 32),
              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: Column(
                    children: [
                      _RoleCard(
                        icon: Icons.business_center_rounded,
                        color: AppColors.primary,
                        title: 'Бренд',
                        description:
                            'Ищу блогеров, создаю рекламные кампании, нахожу исполнителей.',
                        onTap: () => _select('brand'),
                      ),
                      const SizedBox(height: 16),
                      _RoleCard(
                        icon: Icons.camera_alt_rounded,
                        color: AppColors.secondary,
                        title: 'Блогер',
                        description:
                            'Нахожу рекламные кампании, откликаюсь и зарабатываю на коллаборациях.',
                        onTap: () => _select('blogger'),
                      ),
                    ],
                  ),
                ),
              Center(
                child: TextButton.icon(
                  onPressed: _loading
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          ),
                  icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                  label: const Text('Вход для администратора'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(description,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
