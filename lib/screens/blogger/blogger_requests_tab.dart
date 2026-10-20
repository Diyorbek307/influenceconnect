import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
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
                  Tab(text: '${tr('nav_matches')} (${matches.length})'),
                  Tab(text: '${tr('interest_brands')} (${interested.length})'),
                  Tab(text: '${tr('my_responses')} (${myApplications.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    matches.isEmpty
                        ? EmptyState(
                            icon: Icons.favorite_border_rounded,
                            title: tr('empty_matches_t'),
                            subtitle: tr('empty_matches_s'),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: matches
                                .map((m) => _brandTile(context, m.brand,
                                    subtitle:
                                        '${tr('campaign_one')}: ${m.campaign.title}',
                                    matched: true))
                                .toList(),
                          ),
                    interested.isEmpty
                        ? EmptyState(
                            icon: Icons.visibility_outlined,
                            title: tr('no_responses_t'),
                            subtitle: tr('empty_matches_s'),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: interested
                                .map((b) => _brandTile(context, b,
                                    subtitle: b.category))
                                .toList(),
                          ),
                    myApplications.isEmpty
                        ? EmptyState(
                            icon: Icons.send_outlined,
                            title: tr('no_responses_t'),
                            subtitle: tr('change_filter_requests'),
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
