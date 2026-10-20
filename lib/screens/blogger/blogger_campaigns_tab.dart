import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../models/campaign.dart';
import '../../widgets/cards.dart';
import '../../widgets/category_filter.dart';
import '../../widgets/common.dart';
import '../../widgets/swipe_deck.dart';

/// Лента кампаний для блогера с фильтром по категории.
class BloggerCampaignsTab extends StatefulWidget {
  const BloggerCampaignsTab({super.key});

  @override
  State<BloggerCampaignsTab> createState() => _BloggerCampaignsTabState();
}

class _BloggerCampaignsTabState extends State<BloggerCampaignsTab> {
  String _category = 'Все';

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;
    final blogger = repo.currentUser!;
    var campaigns = repo.discoverCampaignsFor(blogger.id);
    if (_category != 'Все') {
      campaigns = campaigns.where((c) => c.category == _category).toList();
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
            child: SwipeDeck<Campaign>(
              key: ValueKey(_category),
              items: campaigns,
              saveEnabled: false,
              emptyState: EmptyState(
                icon: Icons.done_all_rounded,
                title: _category == 'Все'
                    ? 'Новых кампаний нет'
                    : 'Нет кампаний в категории «$_category»',
                subtitle: 'Смените фильтр или проверьте раздел «Запросы».',
                action: OutlinedButton.icon(
                  onPressed: () => repo.refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Обновить'),
                ),
              ),
              cardBuilder: (_, c) => CampaignSwipeCard(
                  campaign: c, brand: repo.profileById(c.brandId)),
              onSwipe: (c, action) {
                final liked = action == SwipeAction.like;
                repo.swipe(
                  fromId: blogger.id,
                  targetType: 'campaign',
                  targetId: c.id,
                  liked: liked,
                );
                if (liked) showSnack(context, 'Вы откликнулись на «${c.title}»');
              },
            ),
          ),
        ),
      ],
    );
  }
}
