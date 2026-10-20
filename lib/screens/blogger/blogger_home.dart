import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../l10n/l10n.dart';
import '../../widgets/common.dart';
import '../shared/messages_tab.dart';
import '../shared/profile_tab.dart';
import 'blogger_campaigns_tab.dart';
import 'blogger_requests_tab.dart';

class BloggerHome extends StatefulWidget {
  const BloggerHome({super.key});

  @override
  State<BloggerHome> createState() => _BloggerHomeState();
}

class _BloggerHomeState extends State<BloggerHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final titles = [
          tr('nav_campaigns'),
          tr('nav_requests'),
          tr('title_messages'),
          tr('nav_profile'),
        ];
        const pages = [
          BloggerCampaignsTab(),
          BloggerRequestsTab(),
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
                  label: tr('nav_campaigns')),
              NavigationDestination(
                  icon: const Icon(Icons.favorite_outline),
                  selectedIcon: const Icon(Icons.favorite),
                  label: tr('nav_requests')),
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
