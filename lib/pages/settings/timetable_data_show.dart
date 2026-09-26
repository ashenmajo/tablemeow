///timetable_data_show.dart
///该文件是课表数据展示页,从data_setting_page.dart的“数据管理”选项进入
library;

import 'package:flutter/material.dart';
import 'package:tablemeow/models/course_session.dart';
import 'package:tablemeow/models/semester.dart';

import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';

class TimetableDataShow extends StatelessWidget {
  const TimetableDataShow({super.key, required this.sorted});
  final List<CourseSession> sorted;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('课表数据')),
      body: PageScaffold(
        children: <Widget>[
          SectionCard(
            title: '数据',
            child: Column(
              children: <Widget>[
                for (int index = 0; index < sorted.length; index++) ...[
                  ListTile(
                    title: Text(sorted[index].name),
                    subtitle: Text(
                      '${Semester.weekdayNames[sorted[index].weekday - 1]} '
                      '${sorted[index].periodLabel}·${sorted[index].weeksLabel}',
                    ),
                  ),
                  if (index != sorted.length - 1) const Divider(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
