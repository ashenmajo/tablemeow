import 'package:flutter/material.dart';

/// 底部导航的页面标识。
enum AppTab { timetable, today, settings }

/// 底部导航的一个入口。
@immutable
class AppDestination {
  const AppDestination({
    required this.tab,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final AppTab tab;

  /// 导航栏文字。
  final String label;

  /// 未选中与选中时使用的图标。
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
  //“导入”迁移到“课表”右上角
  // AppDestination(
  //   tab: AppTab.importData,
  //   label: '导入',
  //   icon: Icons.cloud_download_outlined,
  //   selectedIcon: Icons.cloud_download,
  // ),
  AppDestination(
    tab: AppTab.settings,
    label: '设置',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

/// 按页面标识取入口定义。
AppDestination destinationOf(AppTab tab) => appDestinations.firstWhere(
  (AppDestination destination) => destination.tab == tab,
);

/// [tab] 在底部导航中的下标。
int indexOfTab(AppTab tab) =>
    appDestinations.indexWhere((AppDestination d) => d.tab == tab);
