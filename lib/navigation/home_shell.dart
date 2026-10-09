//home-shell.dart
//负责app的主框架，并处理定时任务
import 'dart:async';

import 'package:flutter/material.dart';

import '../pages/settings_page.dart';
import '../pages/timetable_page.dart';
import '../pages/today_page.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import 'app_destination.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  Timer? _minuteTicker;
  AppState? _state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = AppScope.of(context);
    // 每分钟刷一次，更新课表时间线和今日状态
    _minuteTicker ??= Timer.periodic(
      const Duration(minutes: 1),
      (_) => _state?.refresh(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;
    // 从后台回来时间可能过了很久，跳回本周再刷新
    _state?.goToCurrentWeek();
    _state?.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _minuteTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final index = indexOfTab(state.selectedTab);

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: [for (final d in appDestinations) _pageOf(d.tab)],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => state.openTab(appDestinations[i].tab),
        destinations: [
          for (final d in appDestinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }

  Widget _pageOf(AppTab tab) => switch (tab) {
    AppTab.timetable => const TimetablePage(),
    AppTab.today => const TodayPage(),
    AppTab.settings => const SettingsPage(),
  };
}
