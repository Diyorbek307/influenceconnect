import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../models/profile.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import '../../widgets/user_avatar.dart';
import '../shared/chat_screen.dart';

class BloggerRequestsTab extends StatelessWidget {
  const BloggerRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final repo = AppRepository.instance;
        final id = repo.currentUser!.id;
        final matches = repo.matchesForBlogger(id);
        final interested = repo.brandsInterestedIn(id);
        final myApplications = repo.likedCampaignsBy(id);

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                labelColor: AppColors.primary,
                indicatorColor: AppColors.primary,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: 'Мэтчи (${matches.length})'),
                  Tab(text: 'Интерес брендов (${interested.length})'),
                  Tab(text: 'Мои отклики (${myApplications.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    matches.isEmpty
                        ? const EmptyState(
                            icon: Icons.favorite_border_rounded,
                            title: 'Совпадений пока нет',
                            subtitle:
                                'Мэтч появится, когда бренд и вы проявите взаимный интерес.',
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: matches
                                .map((m) => _brandTile(context, m.brand,
                                    subtitle: 'Кампания: ${m.campaign.title}',
                                    matched: true))
                                .toList(),
                          ),
                    interested.isEmpty
                        ? const EmptyState(
                            icon: Icons.visibility_outlined,
                            title: 'Пока нет интереса',
                            subtitle:
                                'Здесь появятся бренды, которые заинтересовались вами.',
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: interested
                                .map((b) => _brandTile(context, b,
                                    subtitle: b.category))
                                .toList(),
                          ),
                    myApplications.isEmpty
                        ? const EmptyState(
                            icon: Icons.send_outlined,
                            title: 'Нет откликов',
                            subtitle:
                                'Свайпайте кампании вправо, чтобы откликнуться.',
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: myApplications
                                .map((c) => CampaignListItem(
                                      campaign: c,
                                      trailing: const Icon(
                                          Icons.check_circle_rounded,
                                          color: AppColors.success),
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

  Widget _brandTile(BuildContext context, Profile brand,
      {required String subtitle, bool matched = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatScreen(otherUserId: brand.id)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: UserAvatar(
            imageUrl: brand.avatarUrl, initials: brand.initials, size: 52),
        title: Text(brand.displayName,
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        trailing: matched
            ? const Icon(Icons.verified_rounded, color: AppColors.success)
            : const Icon(Icons.business_rounded, color: AppColors.primary),
      ),
    );
  }
}
