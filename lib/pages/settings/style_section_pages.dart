import 'package:flutter/material.dart';

import '../../models/timetable_style.dart';
import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';
import '../../widgets/timetable_style_sections.dart';

/// 「配色」「显示内容」「主题」三页共用的骨架。
class _StyleSectionPage extends StatelessWidget {
  const _StyleSectionPage({
    required this.title,
    required this.description,
    required this.sectionBuilder,
  });

  /// 页面标题，同时用作卡片标题。
  final String title;

  /// 页面顶部的一句说明。
  final String description;

  /// 用当前的外观设置造出要显示的区块。
  final Widget Function(
    TimetableStyle style,
    ValueChanged<TimetableStyle> onChanged,
  )
  sectionBuilder;

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PageScaffold(
        description: description,
        children: <Widget>[
          SectionCard(
            title: title,
            child: sectionBuilder(state.style, state.updateStyle),
          ),
        ],
      ),
    );
  }
}

/// 配色
class ColorSettingsPage extends StatelessWidget {
  const ColorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _StyleSectionPage(
      title: '配色',
      description: '课程块的颜色方案。',
      sectionBuilder: (
        TimetableStyle style,
        ValueChanged<TimetableStyle> onChanged,
      ) => TimetableColorSection(style: style, onChanged: onChanged),
    );
  }
}

/// 显示内容
class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _StyleSectionPage(
      title: '显示内容',
      description: '格子里显示哪些信息。',
      sectionBuilder: (
        TimetableStyle style,
        ValueChanged<TimetableStyle> onChanged,
      ) => TimetableDisplaySection(style: style, onChanged: onChanged),
    );
  }
}

/// 主题
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _StyleSectionPage(
      title: '主题',
      description: '明暗模式与纯黑模式。',
      sectionBuilder: (
        TimetableStyle style,
        ValueChanged<TimetableStyle> onChanged,
      ) => TimetableThemeSection(style: style, onChanged: onChanged),
    );
  }
}
