import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
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
  static const _titles = ['Кампании', 'Запросы', 'Профиль'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        const pages = [
          BloggerCampaignsTab(),
          BloggerRequestsTab(),
          ProfileTab(),
        ];
        return Scaffold(
          appBar: AppBar(title: Text(_titles[_index])),
          body: SafeArea(child: pages[_index]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Кампании'),
              NavigationDestination(
                  icon: Icon(Icons.favorite_outline),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Запросы'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Профиль'),
            ],
          ),
        );
      },
    );
  }
}
