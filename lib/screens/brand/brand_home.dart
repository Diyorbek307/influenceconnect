import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../widgets/common.dart';
import 'brand_discover_tab.dart';
import 'brand_campaigns_tab.dart';
import 'brand_matches_tab.dart';
import '../shared/profile_tab.dart';

/// Главная оболочка бренда с нижней навигацией.
class BrandHome extends StatefulWidget {
  const BrandHome({super.key});

  @override
  State<BrandHome> createState() => _BrandHomeState();
}

class _BrandHomeState extends State<BrandHome> {
  int _index = 0;

  static const _titles = ['Поиск блогеров', 'Мои кампании', 'Совпадения', 'Профиль'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        final pages = const [
          BrandDiscoverTab(),
          BrandCampaignsTab(),
          BrandMatchesTab(),
          ProfileTab(),
        ];
        return Scaffold(
          appBar: GradientAppBar(title: _titles[_index]),
          body: SafeArea(child: pages[_index]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore),
                  label: 'Поиск'),
              NavigationDestination(
                  icon: Icon(Icons.campaign_outlined),
                  selectedIcon: Icon(Icons.campaign),
                  label: 'Кампании'),
              NavigationDestination(
                  icon: Icon(Icons.favorite_outline),
                  selectedIcon: Icon(Icons.favorite),
                  label: 'Совпадения'),
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
