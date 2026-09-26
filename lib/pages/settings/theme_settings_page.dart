import 'package:flutter/material.dart';

import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';
import '../../widgets/timetable_style_sections.dart';

/// 主题
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('主题')),
      body: PageScaffold(
        description: '明暗模式与纯黑模式。',
        children: <Widget>[
          SectionCard(
            title: '主题',
            child: TimetableThemeSection(
              style: state.style,
              onChanged: state.updateStyle,
            ),
          ),
        ],
      ),
    );
  }
}
