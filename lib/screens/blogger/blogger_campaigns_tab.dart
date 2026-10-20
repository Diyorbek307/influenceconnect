import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
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
                    ? tr('no_new_campaigns')
                    : tr('no_campaigns_cat'),
                subtitle: tr('change_filter_requests'),
                action: OutlinedButton.icon(
                  onPressed: () => repo.refresh(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(tr('refresh')),
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
                if (liked) {
                  showSnack(context, '${tr('you_responded')} «${c.title}»');
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
