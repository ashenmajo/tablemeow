import 'package:flutter/material.dart';

import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';
import '../../widgets/timetable_style_sections.dart';

/// 配色
class ColorSettingsPage extends StatelessWidget {
  const ColorSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('配色')),
      body: PageScaffold(
        description: '课程块的颜色方案。',
        children: <Widget>[
          SectionCard(
            title: '配色',
            child: TimetableColorSection(
              style: state.style,
              onChanged: state.updateStyle,
            ),
          ),
        ],
      ),
    );
  }
}
