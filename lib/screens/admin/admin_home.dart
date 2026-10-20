import 'package:flutter/material.dart';

import '../../data/app_repository.dart';
import '../../widgets/common.dart';
import '../nav_helper.dart';
import 'admin_campaigns_tab.dart';
import 'admin_dashboard_tab.dart';
import 'admin_users_tab.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;
  static const _titles = ['Дашборд', 'Пользователи', 'Кампании'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppRepository.instance,
      builder: (context, _) {
        const pages = [
          AdminDashboardTab(),
          AdminUsersTab(),
          AdminCampaignsTab(),
        ];
        return Scaffold(
          appBar: GradientAppBar(
            title: 'Админ · ${_titles[_index]}',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF8A3D), Color(0xFFFF2D74)],
            ),
            actions: [
              IconButton(
                tooltip: 'Выйти',
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => AppNav.logout(context),
              ),
            ],
          ),
          body: SafeArea(child: pages[_index]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Дашборд'),
              NavigationDestination(
                  icon: Icon(Icons.group_outlined),
                  selectedIcon: Icon(Icons.group),
                  label: 'Пользователи'),
              NavigationDestination(
                  icon: Icon(Icons.campaign_outlined),
                  selectedIcon: Icon(Icons.campaign),
                  label: 'Кампании'),
            ],
          ),
        );
      },
    );
  }
}
