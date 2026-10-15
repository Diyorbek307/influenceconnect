import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../models/campaign.dart';
import '../../theme/app_colors.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';
import 'campaign_detail_screen.dart';
import 'campaign_form_screen.dart';

class BrandCampaignsTab extends StatelessWidget {
  const BrandCampaignsTab({super.key});

  Future<void> _create(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CampaignFormScreen()),
    );
  }

  Future<void> _edit(BuildContext context, Campaign c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CampaignFormScreen(existing: c)),
    );
  }

  void _open(BuildContext context, Campaign c) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaignId: c.id)),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Campaign c) async {
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
      await AppRepository.instance.deleteCampaign(c.id);
      if (context.mounted) showSnack(context, 'Кампания удалена');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final repo = AppRepository.instance;
        final campaigns = repo.campaignsByBrand(repo.currentUser!.id);

        return Scaffold(
          body: campaigns.isEmpty
              ? EmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'У вас пока нет кампаний',
                  subtitle: 'Создайте первую кампанию, чтобы блогеры могли откликнуться.',
                  action: ElevatedButton.icon(
                    onPressed: () => _create(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Создать кампанию'),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => repo.refresh(),
                  child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: campaigns.length,
                  itemBuilder: (context, i) {
                    final c = campaigns[i];
                    final applicants = repo
                        .applicationsForBrand(c.brandId)
                        .where((a) => a.campaign.id == c.id)
                        .length;
                    return CampaignListItem(
                      campaign: c,
                      onTap: () => _open(context, c),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (applicants > 0)
                            StatusBadge(
                                text: '$applicants откл.',
                                color: AppColors.primary),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              switch (v) {
                                case 'edit':
                                  _edit(context, c);
                                case 'open':
                                  _open(context, c);
                                case 'toggle':
                                  repo.setCampaignStatus(
                                      c.id, c.isActive ? 'closed' : 'active');
                                case 'delete':
                                  _confirmDelete(context, c);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                  value: 'open', child: Text('Открыть')),
                              const PopupMenuItem(
                                  value: 'edit', child: Text('Редактировать')),
                              PopupMenuItem(
                                  value: 'toggle',
                                  child: Text(c.isActive
                                      ? 'Закрыть'
                                      : 'Активировать')),
                              const PopupMenuItem(
                                  value: 'delete', child: Text('Удалить')),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ),
          floatingActionButton: campaigns.isEmpty
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _create(context),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Кампания'),
                ),
        );
      },
    );
  }
}
