import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
import '../../models/profile.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations.dart';
import '../../widgets/common.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/user_avatar.dart';
import '../nav_helper.dart';
import 'profile_edit_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('logout_q')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr('logout'))),
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
                    text: user.isBrand ? tr('brand') : tr('blogger'),
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
              _section(context, tr('about_me'), user.bio),
            ],
            const SizedBox(height: 16),
            _infoRow(context, Icons.category_rounded,
                user.isBrand ? tr('field_industry') : tr('field_niche'),
                user.category.isEmpty ? '—' : user.category),
            _infoRow(context, Icons.place_rounded, tr('city'),
                user.location.isEmpty ? '—' : user.location),
            if (user.isBlogger)
              _infoRow(context, Icons.public_rounded, tr('field_platform'),
                  user.platform.isEmpty ? '—' : user.platform),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.language_rounded,
                    size: 20, color: AppColors.lightTextMuted),
                const SizedBox(width: 12),
                Text(tr('language'),
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                const LanguageSwitcher(),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              ),
              icon: const Icon(Icons.edit_outlined),
              label: Text(tr('edit_profile')),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
              icon: const Icon(Icons.logout_rounded),
              label: Text(tr('logout')),
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
              label: tr('followers'),
              color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
              icon: Icons.favorite_rounded,
              value: '${user.engagement.toStringAsFixed(1)}%',
              label: tr('engagement'),
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
