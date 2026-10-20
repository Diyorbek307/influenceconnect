import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
import '../../models/profile.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import 'chat_screen.dart';

/// Полный профиль блогера: охват, вовлечённость, ниша, описание + кнопка чата.
class BloggerDetailScreen extends StatelessWidget {
  final String bloggerId;
  const BloggerDetailScreen({super.key, required this.bloggerId});

  @override
  Widget build(BuildContext context) {
    final blogger = AppRepository.instance.profileById(bloggerId);
    if (blogger == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
            icon: Icons.person_off_rounded, title: tr('profile_not_found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkCover(
                      url: blogger.avatarUrl, fallbackIcon: Icons.person_rounded),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.4, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(blogger.displayName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.place_rounded,
                                size: 15, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(blogger.location,
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                            icon: Icons.people_alt_rounded,
                            value: blogger.followersLabel,
                            label: 'Подписчики',
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                            icon: Icons.favorite_rounded,
                            value: '${blogger.engagement.toStringAsFixed(1)}%',
                            label: 'Вовлечённость',
                            color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      InfoChip(
                          icon: Icons.category_rounded,
                          label: blogger.category),
                      InfoChip(
                          icon: Icons.public_rounded,
                          label: blogger.platform,
                          color: AppColors.secondary),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(tr('about_blogger'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    blogger.bio.isEmpty ? tr('no_bio') : blogger.bio,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  GradientButton(
                    label: tr('write_msg'),
                    icon: Icons.chat_bubble_rounded,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => ChatScreen(otherUserId: blogger.id)),
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

/// Открыть детальный профиль блогера.
void openBloggerDetail(BuildContext context, Profile blogger) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => BloggerDetailScreen(bloggerId: blogger.id)),
  );
}
