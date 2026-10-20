import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../../utils/iterable_ext.dart';
import '../../widgets/cards.dart';
import '../../widgets/common.dart';

/// Детали кампании бренда: описание, статус и список откликнувшихся блогеров.
class CampaignDetailScreen extends StatelessWidget {
  final String campaignId;
  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final repo = AppRepository.instance;
        final campaign =
            repo.allCampaigns.where((c) => c.id == campaignId).firstOrNull;
        if (campaign == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
                icon: Icons.error_outline_rounded,
                title: tr('profile_not_found')),
          );
        }

        final applicants = repo
            .applicationsForBrand(campaign.brandId)
            .where((a) => a.campaign.id == campaign.id)
            .map((a) => a.blogger)
            .toList();

        return Scaffold(
          appBar: AppBar(title: Text(tr('campaign_one'))),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: NetworkCover(url: campaign.imageUrl, height: 200),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(campaign.title,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InfoChip(
                      icon: Icons.payments_outlined,
                      label: campaign.budgetLabel,
                      color: AppColors.success),
                  InfoChip(
                      icon: Icons.category_rounded, label: campaign.category),
                  InfoChip(
                    icon: Icons.circle,
                    label: campaign.isActive
                        ? tr('status_active')
                        : campaign.isPending
                            ? tr('status_pending')
                            : tr('status_closed'),
                    color: campaign.isActive
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(campaign.description,
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(tr('responses'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(width: 8),
                  StatusBadge(
                      text: '${applicants.length}', color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 12),
              if (applicants.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(
                    icon: Icons.inbox_outlined,
                    title: tr('no_responses_t'),
                    subtitle: tr('empty_chats_s'),
                  ),
                )
              else
                ...applicants.map((b) => BloggerListItem(
                      blogger: b,
                      trailing: const Icon(Icons.chat_bubble_outline_rounded,
                          color: AppColors.primary),
                    )),
            ],
          ),
        );
      },
    );
  }
}
