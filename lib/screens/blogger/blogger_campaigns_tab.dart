import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../models/campaign.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/swipe_deck.dart';

/// Лента кампаний для блогера: вправо — откликнуться, влево — пропустить.
class BloggerCampaignsTab extends StatelessWidget {
  const BloggerCampaignsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;
    final blogger = repo.currentUser!;
    final campaigns = repo.discoverCampaignsFor(blogger.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SwipeDeck<Campaign>(
        items: campaigns,
        saveEnabled: false,
        emptyState: const EmptyState(
          icon: Icons.done_all_rounded,
          title: 'Новых кампаний нет',
          subtitle:
              'Вы просмотрели все актуальные предложения. Проверьте раздел «Запросы».',
        ),
        cardBuilder: (_, c) =>
            CampaignSwipeCard(campaign: c, brand: repo.profileById(c.brandId)),
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
    );
  }
}
