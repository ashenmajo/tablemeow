import 'package:flutter/material.dart';

import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';
import '../../widgets/timetable_style_sections.dart';

/// 显示内容
class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('显示内容')),
      body: PageScaffold(
        description: '格子里显示哪些信息。',
        children: <Widget>[
          SectionCard(
            title: '显示内容',
            child: TimetableDisplaySection(
              style: state.style,
              onChanged: state.updateStyle,
            ),
          ),
        ],
      ),
    );
  }
}
