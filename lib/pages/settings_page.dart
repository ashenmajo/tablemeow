///settings_page.dart
///该文件是所有设置和信息的入口页
///包含了：布局与尺寸、配色、显示内容、节次时间、学期设置、主题、数据管理、关于
library;

import 'package:flutter/material.dart';

import '../models/semester.dart';
import '../models/timetable_style.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../utils/date_format.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section_card.dart';
import 'settings/about_page.dart';
import 'settings/data_settings_page.dart';
import 'settings/layout_settings_page.dart';
import 'settings/period_settings_page.dart';
import 'settings/semester_settings_page.dart';
import 'settings/style_section_pages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: PageScaffold(
        children: <Widget>[
          _buildTimetableGroup(context, state),
          _buildThemeGroup(context, state),
          _buildDataGroup(context, state),
          _buildAboutGroup(context),
        ],
      ),
    );
  }

  Widget _buildTimetableGroup(BuildContext context, AppState state) {
    final Semester semester = state.semester;
    final TimetableStyle style = state.style;
    return SectionCard(
      title: '课表',
      icon: Icons.calendar_view_week_outlined,
      child: Column(
        children: <Widget>[
          _SettingsTile(
            icon: Icons.grid_view_outlined,
            title: '布局与尺寸',
            subtitle:
                '每节 ${style.autoCellHeight ? '自动' : '${style.cellHeight.round()} dp'}'
                ' · 字号 ${style.fontScale.toStringAsFixed(2)}×'
                ' · ${_lineHeightLabel(style.lineHeight)}',
            onTap: () => _open(context, const LayoutSettingsPage()),
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: '配色',
            subtitle: _colorModeLabel(style.colorMode),
            onTap: () => _open(context, const ColorSettingsPage()),
          ),
          _SettingsTile(
            icon: Icons.article_outlined,
            title: '显示内容',
            subtitle: [
              if (style.showLocation) '地点',
              if (style.showTeacher) '教师',
              if (style.nameStyle == CourseNameStyle.alias) '别名',
            ].join(' · '),
            onTap: () => _open(context, const DisplaySettingsPage()),
          ),
          _SettingsTile(
            icon: Icons.schedule_outlined,
            title: '节次时间',
            subtitle: '共 ${semester.periods.length} 节',
            onTap: () => _open(context, const PeriodSettingsPage()),
          ),
          _SettingsTile(
            icon: Icons.event_outlined,
            title: '学期设置',
            subtitle:
                '第 1 周周一 ${formatMonthDay(semester.startDate)} · '
                '${semester.totalWeeks} 周',
            onTap: () => _open(context, const SemesterSettingsPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGroup(BuildContext context, AppState state) {
    final TimetableStyle style = state.style;
    return SectionCard(
      title: '主题',
      icon: Icons.brightness_6_outlined,
      child: _SettingsTile(
        icon: Icons.contrast,
        title: '主题',
        subtitle:
            '${_themeModeLabel(style.themeMode)}'
            '${style.oledBlack ? ' · 纯黑' : ''}',
        onTap: () => _open(context, const ThemeSettingsPage()),
      ),
    );
  }

  Widget _buildDataGroup(BuildContext context, AppState state) {
    return SectionCard(
      title: '数据',
      icon: Icons.storage_outlined,
      child: _SettingsTile(
        icon: Icons.folder_outlined,
        title: '数据管理',
        subtitle:
            '${state.sessions.length} 条上课安排 · '
            '${state.timetable.courseCount} 门课程',
        onTap: () => _open(context, const DataSettingsPage()),
      ),
    );
  }

  Widget _buildAboutGroup(BuildContext context) {
    return SectionCard(
      child: _SettingsTile(
        icon: Icons.info_outline,
        title: '关于',
        subtitle: '版本 1.0.0',
        onTap: () => _open(context, const AboutPage()),
      ),
    );
  }

  static String _lineHeightLabel(CourseLineHeight value) => switch (value) {
    CourseLineHeight.compact => '紧凑',
    CourseLineHeight.standard => '标准',
    CourseLineHeight.relaxed => '宽松',
  };

  static String _colorModeLabel(CourseColorMode value) => switch (value) {
    CourseColorMode.theme => '跟随主题色',
    CourseColorMode.custom => '自定义色板',
    CourseColorMode.single => '单色',
  };

  static String _themeModeLabel(AppThemeMode value) => switch (value) {
    AppThemeMode.system => '跟随系统',
    AppThemeMode.light => '亮色',
    AppThemeMode.dark => '暗色',
  };

  static void _open(BuildContext context, Widget page) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) => page));
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
