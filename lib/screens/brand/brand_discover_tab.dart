import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../models/profile.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/swipe_deck.dart';

/// Лента блогеров для бренда: свайп влево (пропуск), вправо (интерес),
/// вверх (сохранить в избранное).
class BrandDiscoverTab extends StatelessWidget {
  const BrandDiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;
    final brand = repo.currentUser!;
    final bloggers = repo.discoverBloggersFor(brand.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SwipeDeck<Profile>(
        items: bloggers,
        saveEnabled: true,
        emptyState: EmptyState(
          icon: Icons.done_all_rounded,
          title: 'Вы просмотрели всех блогеров',
          subtitle:
              'Новые авторы появятся здесь позже. Загляните в раздел «Совпадения».',
          action: OutlinedButton.icon(
            onPressed: () => repo.refresh(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Обновить'),
          ),
        ),
        cardBuilder: (_, blogger) => BloggerSwipeCard(blogger: blogger),
        onSwipe: (blogger, action) {
          final liked = action != SwipeAction.dislike;
          repo.swipe(
            fromId: brand.id,
            targetType: 'blogger',
            targetId: blogger.id,
            liked: liked,
          );
          if (action == SwipeAction.like) {
            showSnack(context, 'Вы проявили интерес к ${blogger.displayName}');
          } else if (action == SwipeAction.save) {
            showSnack(context, '${blogger.displayName} сохранён(а)');
          }
        },
      ),
    );
  }
}
