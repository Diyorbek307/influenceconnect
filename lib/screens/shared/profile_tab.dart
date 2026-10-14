import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../models/profile.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations.dart';
import '../../widgets/common.dart';
import '../../widgets/user_avatar.dart';
import '../nav_helper.dart';
import 'profile_edit_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Выйти')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await AppNav.logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final user = AppRepository.instance.currentUser;
        if (user == null) return const SizedBox.shrink();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Appear(
              child: Center(
              child: Column(
                children: [
                  UserAvatar(
                    imageUrl: user.avatarUrl,
                    initials: user.initials,
                    size: 96,
                    ringColor: AppColors.role(user.role),
                  ),
                  const SizedBox(height: 16),
                  Text(user.displayName,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 6),
                  StatusBadge(
                    text: user.isBrand ? 'Бренд' : 'Блогер',
                    color: AppColors.role(user.role),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            ),
            const SizedBox(height: 24),
            if (user.isBlogger) _bloggerStats(context, user),
            if (user.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              _section(context, 'О себе', user.bio),
            ],
            const SizedBox(height: 16),
            _infoRow(context, Icons.category_rounded,
                user.isBrand ? 'Индустрия' : 'Ниша',
                user.category.isEmpty ? '—' : user.category),
            _infoRow(context, Icons.place_rounded, 'Город',
                user.location.isEmpty ? '—' : user.location),
            if (user.isBlogger)
              _infoRow(context, Icons.public_rounded, 'Платформа',
                  user.platform.isEmpty ? '—' : user.platform),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Редактировать профиль'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Выйти'),
            ),
          ],
        );
      },
    );
  }

  Widget _bloggerStats(BuildContext context, Profile user) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
              icon: Icons.people_alt_rounded,
              value: user.followersLabel,
              label: 'Подписчики',
              color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
              icon: Icons.favorite_rounded,
              value: '${user.engagement.toStringAsFixed(1)}%',
              label: 'Вовлечённость',
              color: AppColors.secondary),
        ),
      ],
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.lightTextMuted),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontSize: 15)),
        ],
      ),
    );
  }
}
