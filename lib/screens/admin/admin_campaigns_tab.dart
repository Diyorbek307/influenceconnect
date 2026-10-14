import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../models/campaign.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

class AdminCampaignsTab extends StatelessWidget {
  const AdminCampaignsTab({super.key});

  Future<void> _confirmDelete(
      BuildContext context, Campaign c, AppRepository repo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить кампанию?'),
        content: Text('«${c.title}» будет удалена безвозвратно.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.deleteCampaign(c.id);
      if (context.mounted) showSnack(context, 'Кампания удалена');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final repo = AppRepository.instance;
        final campaigns = repo.allCampaigns.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (campaigns.isEmpty) {
          return const EmptyState(
            icon: Icons.campaign_outlined,
            title: 'Кампаний нет',
            subtitle: 'Когда бренды создадут кампании, они появятся здесь.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: campaigns.length,
          itemBuilder: (context, i) {
            final c = campaigns[i];
            final brand = repo.profileById(c.brandId);
            return CampaignListItem(
              campaign: c,
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  switch (v) {
                    case 'toggle':
                      await repo.setCampaignStatus(
                          c.id, c.isActive ? 'closed' : 'active');
                      if (context.mounted) {
                        showSnack(context,
                            c.isActive ? 'Кампания закрыта' : 'Кампания активирована');
                      }
                    case 'delete':
                      _confirmDelete(context, c, repo);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'toggle',
                      child: Text(c.isActive ? 'Закрыть' : 'Активировать')),
                  const PopupMenuItem(value: 'delete', child: Text('Удалить')),
                ],
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.more_vert_rounded),
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text('Бренд: ${brand?.displayName ?? 'неизвестен'}',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 12),
                        Text(c.description,
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            InfoChip(
                                icon: Icons.payments_outlined,
                                label: c.budgetLabel,
                                color: AppColors.success),
                            const SizedBox(width: 8),
                            InfoChip(
                                icon: Icons.category_rounded,
                                label: c.category),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
