import 'package:flutter/material.dart';

import '../models/campaign.dart';
import '../models/profile.dart';
import '../theme/app_colors.dart';
import 'common.dart';
import 'user_avatar.dart';

/// Крупная карточка блогера для свайп-колоды бренда.
class BloggerSwipeCard extends StatelessWidget {
  final Profile blogger;
  const BloggerSwipeCard({super.key, required this.blogger});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Фото во весь экран с запасным ярким градиентом и крупными инициалами.
          _BloggerPhoto(blogger: blogger),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black38, Colors.transparent, Colors.black, Colors.black],
                stops: [0.0, 0.35, 0.8, 1.0],
              ),
            ),
          ),
          // Бейдж категории сверху
          Positioned(
            top: 18,
            left: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      size: 15, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(blogger.category,
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        blogger.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.verified_rounded,
                        color: Color(0xFF3BA7FF), size: 24),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(
                        icon: Icons.category_rounded,
                        label: blogger.category,
                        color: Colors.white),
                    InfoChip(
                        icon: Icons.people_alt_rounded,
                        label: '${blogger.followersLabel} подписчиков',
                        color: Colors.white),
                    InfoChip(
                        icon: Icons.favorite_rounded,
                        label: '${blogger.engagement.toStringAsFixed(1)}% ER',
                        color: Colors.white),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.place_rounded,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(blogger.location,
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 12),
                    const Icon(Icons.public_rounded,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Text(blogger.platform,
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  blogger.bio,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Фото блогера на всю карточку с ярким запасным вариантом (инициалы).
class _BloggerPhoto extends StatelessWidget {
  final Profile blogger;
  const _BloggerPhoto({required this.blogger});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      decoration: const BoxDecoration(gradient: AppColors.vividGradient),
      alignment: Alignment.center,
      child: Text(
        blogger.initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 120,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
    if (blogger.avatarUrl.isEmpty) return fallback;
    return Image.network(
      blogger.avatarUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );
  }
}

/// Крупная карточка кампании для свайп-колоды блогера.
class CampaignSwipeCard extends StatelessWidget {
  final Campaign campaign;
  final Profile? brand;
  const CampaignSwipeCard({super.key, required this.campaign, this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardTheme.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetworkCover(url: campaign.imageUrl),
                Positioned(
                  top: 16,
                  left: 16,
                  child: StatusBadge(
                      text: campaign.budgetLabel, color: AppColors.success),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (brand != null)
                    Row(
                      children: [
                        UserAvatar(
                          imageUrl: brand!.avatarUrl,
                          initials: brand!.initials,
                          size: 36,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(brand!.displayName,
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        InfoChip(
                            icon: Icons.category_rounded,
                            label: campaign.category),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Text(campaign.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      campaign.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Компактная строка блогера для списков.
class BloggerListItem extends StatelessWidget {
  final Profile blogger;
  final Widget? trailing;
  final VoidCallback? onTap;
  const BloggerListItem(
      {super.key, required this.blogger, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: UserAvatar(
            imageUrl: blogger.avatarUrl, initials: blogger.initials, size: 52),
        title: Text(blogger.displayName,
            style: Theme.of(context).textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${blogger.category} · ${blogger.followersLabel} · ${blogger.engagement.toStringAsFixed(1)}% ER',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}

/// Компактная строка кампании для списков.
class CampaignListItem extends StatelessWidget {
  final Campaign campaign;
  final Widget? trailing;
  final VoidCallback? onTap;
  const CampaignListItem(
      {super.key, required this.campaign, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColor = campaign.isActive
        ? AppColors.success
        : campaign.isPending
            ? AppColors.warning
            : AppColors.lightTextMuted;
    final statusText = campaign.isActive
        ? 'Активна'
        : campaign.isPending
            ? 'На модерации'
            : 'Закрыта';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: NetworkCover(
                    url: campaign.imageUrl, width: 64, height: 64),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campaign.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(campaign.budgetLabel,
                        style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        StatusBadge(text: statusText, color: statusColor),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(campaign.category,
                              style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
