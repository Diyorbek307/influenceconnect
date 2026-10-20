import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
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
        title: Text(tr('delete_campaign_q')),
        content: Text(c.title),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('delete')),
          ),
        ],
      ),
    );
    if (ok == true) {
      await repo.deleteCampaign(c.id);
      if (context.mounted) showSnack(context, tr('deleted'));
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
          return EmptyState(
            icon: Icons.campaign_outlined,
            title: tr('no_campaigns_admin_t'),
            subtitle: tr('no_campaigns_s'),
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
                            c.isActive ? tr('status_closed') : tr('status_active'));
                      }
                    case 'delete':
                      _confirmDelete(context, c, repo);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'toggle',
                      child: Text(c.isActive ? tr('menu_close') : tr('menu_activate'))),
                  PopupMenuItem(value: 'delete', child: Text(tr('delete'))),
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
                        Text('${tr('brand')}: ${brand?.displayName ?? '—'}',
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
