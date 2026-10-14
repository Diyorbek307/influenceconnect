import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../models/profile.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/user_avatar.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _filter = 'all'; // all | brand | blogger | blocked
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final repo = AppRepository.instance;
        var users = repo.allProfiles.where((p) => !p.isAdmin).toList();

        users = users.where((u) {
          final matchesFilter = switch (_filter) {
            'brand' => u.isBrand,
            'blogger' => u.isBlogger,
            'blocked' => u.isBlocked,
            _ => true,
          };
          final matchesQuery = _query.isEmpty ||
              u.displayName.toLowerCase().contains(_query.toLowerCase()) ||
              u.email.toLowerCase().contains(_query.toLowerCase());
          return matchesFilter && matchesQuery;
        }).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Поиск по имени или email',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _filterChip('all', 'Все'),
                  _filterChip('brand', 'Бренды'),
                  _filterChip('blogger', 'Блогеры'),
                  _filterChip('blocked', 'Заблокированные'),
                ],
              ),
            ),
            Expanded(
              child: users.isEmpty
                  ? const EmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'Никого не найдено')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: users.length,
                      itemBuilder: (context, i) =>
                          _userTile(context, users[i], repo),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
      ),
    );
  }

  Widget _userTile(BuildContext context, Profile u, AppRepository repo) {
    final roleColor = AppColors.role(u.role);
    final roleLabel = u.isBrand ? 'Бренд' : (u.isBlogger ? 'Блогер' : 'Без роли');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: UserAvatar(
            imageUrl: u.avatarUrl, initials: u.initials, size: 48),
        title: Row(
          children: [
            Flexible(
              child: Text(u.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(width: 8),
            if (u.isBlocked)
              const StatusBadge(text: 'Заблокирован', color: AppColors.danger),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('$roleLabel · ${u.email}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            switch (v) {
              case 'block':
                await repo.setBlocked(u.id, true);
                if (context.mounted) showSnack(context, 'Пользователь заблокирован');
              case 'unblock':
                await repo.setBlocked(u.id, false);
                if (context.mounted) showSnack(context, 'Пользователь разблокирован');
              case 'delete':
                _confirmDelete(context, u, repo);
            }
          },
          itemBuilder: (_) => [
            if (!u.isBlocked)
              const PopupMenuItem(value: 'block', child: Text('Заблокировать')),
            if (u.isBlocked)
              const PopupMenuItem(
                  value: 'unblock', child: Text('Разблокировать')),
            const PopupMenuItem(value: 'delete', child: Text('Удалить')),
          ],
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.more_vert_rounded, size: 20),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, Profile u, AppRepository repo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить пользователя?'),
        content: Text(
            '«${u.displayName}» и все связанные данные будут удалены безвозвратно.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.deleteProfile(u.id);
      if (context.mounted) showSnack(context, 'Пользователь удалён');
    }
  }
}
