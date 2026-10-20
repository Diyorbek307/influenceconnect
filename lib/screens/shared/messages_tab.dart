import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';
import '../../widgets/user_avatar.dart';
import 'chat_screen.dart';

/// Список всех диалогов текущего пользователя (инбокс).
class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final repo = AppRepository.instance;
        final partners = repo.conversationPartners();
        // Сортируем по времени последнего сообщения (свежие сверху).
        partners.sort((a, b) {
          final la = repo.lastMessageWith(a.id)?.createdAt;
          final lb = repo.lastMessageWith(b.id)?.createdAt;
          if (la == null && lb == null) return 0;
          if (la == null) return 1;
          if (lb == null) return -1;
          return lb.compareTo(la);
        });

        if (partners.isEmpty) {
          return EmptyState(
            icon: Icons.forum_outlined,
            title: tr('empty_chats_t'),
            subtitle: tr('empty_chats_s'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: partners.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final p = partners[i];
            final last = repo.lastMessageWith(p.id);
            final preview = last == null
                ? 'Нет сообщений'
                : (last.fromId == repo.currentUser?.id ? 'Вы: ' : '') + last.text;
            final time = last == null
                ? ''
                : '${last.createdAt.hour.toString().padLeft(2, '0')}:${last.createdAt.minute.toString().padLeft(2, '0')}';

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                leading: UserAvatar(
                    imageUrl: p.avatarUrl, initials: p.initials, size: 52),
                title: Text(p.displayName,
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                trailing: Text(time,
                    style: Theme.of(context).textTheme.bodySmall),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(otherUserId: p.id)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
