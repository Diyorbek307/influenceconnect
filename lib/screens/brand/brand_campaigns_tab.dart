import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
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
      await AppRepository.instance.deleteCampaign(c.id);
      if (context.mounted) showSnack(context, tr('deleted'));
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
                  title: tr('no_campaigns_t'),
                  subtitle: tr('no_campaigns_s'),
                  action: ElevatedButton.icon(
                    onPressed: () => _create(context),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(tr('create_campaign')),
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
                                text: '$applicants',
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
                              PopupMenuItem(
                                  value: 'open', child: Text(tr('menu_open'))),
                              PopupMenuItem(
                                  value: 'edit', child: Text(tr('menu_edit'))),
                              PopupMenuItem(
                                  value: 'toggle',
                                  child: Text(c.isActive
                                      ? tr('menu_close')
                                      : tr('menu_activate'))),
                              PopupMenuItem(
                                  value: 'delete', child: Text(tr('delete'))),
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
                  label: Text(tr('campaign_one')),
                ),
        );
      },
    );
  }
}
