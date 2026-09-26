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
    // 每分钟刷新一次「现在」，驱动课表时间线与今日课程状态。
    _minuteTicker ??= Timer.periodic(
      const Duration(minutes: 1),
      (Timer _) => _state?.refresh(),
    );
  }

  /// 从后台回到前台时：时间可能已经过去很久，跳回本周并刷新。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) {
      return;
    }
    _state
      ?..goToCurrentWeek()
      ..refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _minuteTicker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      body: IndexedStack(
        index: indexOfTab(state.selectedTab),
        children: <Widget>[
          for (final AppDestination destination in appDestinations)
            _pageOf(destination.tab),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: indexOfTab(state.selectedTab),
        onDestinationSelected: (int index) =>
            state.openTab(appDestinations[index].tab),
        destinations: <Widget>[
          for (final AppDestination destination in appDestinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }

  Widget _pageOf(AppTab tab) {
    switch (tab) {
      case AppTab.timetable:
        return const TimetablePage();
      case AppTab.today:
        return const TodayPage();
      case AppTab.settings:
        return const SettingsPage();
    }
  }
}
