import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animations.dart';
import '../../widgets/common.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;
    final s = repo.adminStats;

    final cards = [
      (Icons.business_rounded, '${s.brands}', tr('brands'), AppColors.primary),
      (Icons.camera_alt_rounded, '${s.bloggers}', tr('bloggers'), AppColors.secondary),
      (Icons.campaign_rounded, '${s.campaigns}', tr('nav_campaigns'), AppColors.accent),
      (Icons.play_circle_outline_rounded, '${s.activeCampaigns}', tr('active'), AppColors.success),
      (Icons.favorite_rounded, '${s.likes}', tr('likes'), AppColors.danger),
      (Icons.verified_rounded, '${s.matches}', tr('nav_matches'), AppColors.warning),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tr('total_users'),
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 6),
              CountUp(
                value: s.totalUsers,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.block_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text('${tr('blocked_count')}: ${s.blocked}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(tr('metrics'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: cards
              .asMap()
              .entries
              .map((e) => Appear(
                    delay: Duration(milliseconds: 80 * e.key),
                    child: StatCard(
                        icon: e.value.$1,
                        value: e.value.$2,
                        label: e.value.$3,
                        color: e.value.$4),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
