//style_section_pages.dart
//该文件集成了三个页面：配色页、显示内容页、主题页
//因为这三个页面的框架都是一样的，所以集成在一起了

import 'package:flutter/material.dart';

import '../../models/timetable_style.dart';
import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';
import '../../widgets/timetable_style_sections.dart';

class _StyleSectionPage extends StatelessWidget {
  const _StyleSectionPage({
    required this.title,
    required this.description,
    required this.sectionBuilder,
  });

  final String title;
  final String description;

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

/// 配色页
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

/// 显示内容页
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

/// 主题页
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
