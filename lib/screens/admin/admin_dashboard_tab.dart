import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';

class AdminDashboardTab extends StatelessWidget {
  const AdminDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = AppRepository.instance;
    final s = repo.adminStats;

    final cards = [
      (Icons.business_rounded, '${s.brands}', 'Бренды', AppColors.primary),
      (Icons.camera_alt_rounded, '${s.bloggers}', 'Блогеры', AppColors.secondary),
      (Icons.campaign_rounded, '${s.campaigns}', 'Кампании', AppColors.accent),
      (Icons.play_circle_outline_rounded, '${s.activeCampaigns}', 'Активные', AppColors.success),
      (Icons.favorite_rounded, '${s.likes}', 'Лайки', AppColors.danger),
      (Icons.verified_rounded, '${s.matches}', 'Совпадения', AppColors.warning),
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
              const Text('Всего пользователей',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 6),
              Text('${s.totalUsers}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.block_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text('Заблокировано: ${s.blocked}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Метрики', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: cards
              .map((c) => StatCard(
                  icon: c.$1, value: c.$2, label: c.$3, color: c.$4))
              .toList(),
        ),
      ],
    );
  }
}
