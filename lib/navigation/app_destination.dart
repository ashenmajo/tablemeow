/// app_destination.dart
/// 该文件是底部导航栏的数据配置文件
/// by ashenmajo
library;

import 'package:flutter/material.dart';

enum AppTab { timetable, today, settings }

@immutable
class AppDestination {
  const AppDestination({
    required this.tab,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final AppTab tab;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<AppDestination> appDestinations = <AppDestination>[
  AppDestination(
    tab: AppTab.timetable,
    label: '课表',
    icon: Icons.calendar_view_week_outlined,
    selectedIcon: Icons.calendar_view_week,
  ),
  AppDestination(
    tab: AppTab.today,
    label: '今日',
    icon: Icons.today_outlined,
    selectedIcon: Icons.today,
  ),
  AppDestination(
    tab: AppTab.settings,
    label: '设置',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

int indexOfTab(AppTab tab) =>
    appDestinations.indexWhere((AppDestination d) => d.tab == tab);
