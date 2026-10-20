import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../shared/blogger_detail_screen.dart';
import '../shared/chat_screen.dart';

class BrandMatchesTab extends StatelessWidget {
  const BrandMatchesTab({super.key});

  void _openChat(BuildContext context, String id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(otherUserId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final repo = AppRepository.instance;
        final brandId = repo.currentUser!.id;
        final matches = repo.matchesForBrand(brandId);
        final saved = repo.likedBloggersBy(brandId);
        final applications = repo.applicationsForBrand(brandId);

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: '${tr('nav_matches')} (${matches.length})'),
                  Tab(text: '${tr('responses')} (${applications.length})'),
                  Tab(text: '${tr('favorites')} (${saved.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Взаимные совпадения
                    matches.isEmpty
                        ? EmptyState(
                            icon: Icons.favorite_border_rounded,
                            title: tr('empty_matches_t'),
                            subtitle: tr('empty_matches_s'),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: matches
                                .map((m) => BloggerListItem(
                                      blogger: m.blogger,
                                      onTap: () => _openChat(context, m.blogger.id),
                                      trailing: SizedBox(
                                        width: 96,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.verified_rounded,
                                                color: AppColors.success),
                                            const SizedBox(height: 4),
                                            Text(m.campaign.title,
                                                maxLines: 1,
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                    // Отклики на кампании
                    applications.isEmpty
                        ? EmptyState(
                            icon: Icons.inbox_outlined,
                            title: tr('no_responses_t'),
                            subtitle: tr('no_campaigns_s'),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: applications
                                .map((a) => BloggerListItem(
                                      blogger: a.blogger,
                                      onTap: () => _openChat(context, a.blogger.id),
                                      trailing: StatusBadge(
                                          text: a.campaign.budgetLabel,
                                          color: AppColors.success),
                                    ))
                                .toList(),
                          ),
                    // Сохранённые блогеры
                    saved.isEmpty
                        ? EmptyState(
                            icon: Icons.bookmark_border_rounded,
                            title: tr('nothing_liked'),
                            subtitle: tr('change_filter_matches'),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: saved
                                .map((b) => BloggerListItem(
                                      blogger: b,
                                      onTap: () => openBloggerDetail(context, b),
                                      trailing: const Icon(
                                          Icons.chevron_right_rounded),
                                    ))
                                .toList(),
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
