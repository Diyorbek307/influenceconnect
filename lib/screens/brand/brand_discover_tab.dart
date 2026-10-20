import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
import '../../models/profile.dart';
import '../../widgets/cards.dart';
import '../../widgets/category_filter.dart';
import '../../widgets/common.dart';
import '../../widgets/swipe_deck.dart';

/// Лента блогеров для бренда с фильтром по нише.
class BrandDiscoverTab extends StatefulWidget {
  const BrandDiscoverTab({super.key});

  @override
  State<BrandDiscoverTab> createState() => _BrandDiscoverTabState();
}

class _BrandDiscoverTabState extends State<BrandDiscoverTab> {
  String _category = 'Все';

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;
    final brand = repo.currentUser!;
    var bloggers = repo.discoverBloggersFor(brand.id);
    if (_category != 'Все') {
      bloggers = bloggers.where((b) => b.category == _category).toList();
    }

    return Column(
      children: [
        CategoryFilter(
          selected: _category,
          onSelect: (c) => setState(() => _category = c),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SwipeDeck<Profile>(
              key: ValueKey(_category),
              items: bloggers,
              saveEnabled: true,
              emptyState: EmptyState(
                icon: Icons.done_all_rounded,
                title: _category == 'Все'
                    ? tr('all_viewed_bloggers')
                    : tr('no_bloggers_niche'),
                subtitle: tr('change_filter_matches'),
                action: OutlinedButton.icon(
                  onPressed: () => repo.refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(tr('refresh')),
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
                  showSnack(context,
                      '${blogger.displayName}: ${tr('interest_sent')}');
                } else if (action == SwipeAction.save) {
                  showSnack(context,
                      '${blogger.displayName} ${tr('saved_female')}');
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
