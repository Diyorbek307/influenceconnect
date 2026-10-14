import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

class BrandMatchesTab extends StatelessWidget {
  const BrandMatchesTab({super.key});

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
                  Tab(text: 'Мэтчи (${matches.length})'),
                  Tab(text: 'Отклики (${applications.length})'),
                  Tab(text: 'Избранное (${saved.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Взаимные совпадения
                    matches.isEmpty
                        ? const EmptyState(
                            icon: Icons.favorite_border_rounded,
                            title: 'Пока нет совпадений',
                            subtitle:
                                'Мэтч появится, когда вы и блогер проявите взаимный интерес.',
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: matches
                                .map((m) => BloggerListItem(
                                      blogger: m.blogger,
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
                        ? const EmptyState(
                            icon: Icons.inbox_outlined,
                            title: 'Нет откликов',
                            subtitle:
                                'Создайте кампанию — блогеры начнут откликаться.',
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: applications
                                .map((a) => BloggerListItem(
                                      blogger: a.blogger,
                                      trailing: StatusBadge(
                                          text: a.campaign.budgetLabel,
                                          color: AppColors.success),
                                    ))
                                .toList(),
                          ),
                    // Сохранённые блогеры
                    saved.isEmpty
                        ? const EmptyState(
                            icon: Icons.bookmark_border_rounded,
                            title: 'Избранное пусто',
                            subtitle:
                                'Свайпайте блогеров вверх, чтобы сохранить их здесь.',
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: saved
                                .map((b) => BloggerListItem(blogger: b))
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
