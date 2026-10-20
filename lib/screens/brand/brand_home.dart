import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';
import 'brand_discover_tab.dart';
import 'brand_campaigns_tab.dart';
import 'brand_matches_tab.dart';
import '../shared/messages_tab.dart';
import '../shared/profile_tab.dart';

/// Главная оболочка бренда с нижней навигацией.
class BrandHome extends StatefulWidget {
  const BrandHome({super.key});

  @override
  State<BrandHome> createState() => _BrandHomeState();
}

class _BrandHomeState extends State<BrandHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final titles = [
          tr('title_find_bloggers'),
          tr('title_my_campaigns'),
          tr('nav_matches'),
          tr('title_messages'),
          tr('nav_profile'),
        ];
        const pages = [
          BrandDiscoverTab(),
          BrandCampaignsTab(),
          BrandMatchesTab(),
          MessagesTab(),
          ProfileTab(),
        ];
        return Scaffold(
          appBar: GradientAppBar(title: titles[_index]),
          body: SafeArea(child: pages[_index]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.explore_outlined),
                  selectedIcon: const Icon(Icons.explore),
                  label: tr('nav_search')),
              NavigationDestination(
                  icon: const Icon(Icons.campaign_outlined),
                  selectedIcon: const Icon(Icons.campaign),
                  label: tr('nav_campaigns')),
              NavigationDestination(
                  icon: const Icon(Icons.favorite_outline),
                  selectedIcon: const Icon(Icons.favorite),
                  label: tr('nav_matches')),
              NavigationDestination(
                  icon: const Icon(Icons.chat_bubble_outline),
                  selectedIcon: const Icon(Icons.chat_bubble),
                  label: tr('nav_chats')),
              NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: const Icon(Icons.person),
                  label: tr('nav_profile')),
            ],
          ),
        );
      },
    );
  }
}
