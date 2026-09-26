///semester_setting_page.dart
///该文件用于设置第一周周一在哪个日期，以及总的周数
library;

import 'package:flutter/material.dart';

import '../../models/semester.dart';
import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../utils/date_format.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';

class SemesterSettingsPage extends StatefulWidget {
  const SemesterSettingsPage({super.key});

  @override
  State<SemesterSettingsPage> createState() => _SemesterSettingsPageState();
}

class _SemesterSettingsPageState extends State<SemesterSettingsPage> {
  double? _draftTotalWeeks; //这里必须加这个，不然会卡顿,应该是因为每滑动一点就会存储数据的原因

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final Semester semester = state.semester;
    final ThemeData theme = Theme.of(context);
    final double totalWeeks =
        _draftTotalWeeks ?? semester.totalWeeks.toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('学期设置')),
      body: PageScaffold(
        description:
            '课表日期由「第 1 周周一」与总周数推算，'
            '导入教务系统课表前先对齐这里，课程才会落在正确的日期上。',
        children: <Widget>[
          SectionCard(
            title: '起始与周数',
            icon: Icons.event_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.date_range_outlined),
                  title: const Text('第 1 周周一'),
                  subtitle: Text(
                    '${formatMonthDay(semester.startDate)} '
                    '${Semester.weekdayNames[semester.startDate.weekday - 1]}',
                  ),
                  trailing: const Icon(Icons.edit_outlined, size: 18),
                  onTap: () => _pickStartDate(state),
                ),
                Row(
                  children: <Widget>[
                    const Icon(Icons.timelapse_outlined),
                    const SizedBox(width: 16),
                    const Text('总周数'),
                    Expanded(
                      child: Slider(
                        value: totalWeeks,
                        min: 1,
                        max: 30,
                        divisions: 29,
                        label: '${totalWeeks.round()} 周',
                        onChanged: (double value) =>
                            setState(() => _draftTotalWeeks = value),
                        onChangeEnd: (double value) async {
                          await state.updateSemester(
                            semester.copyWith(totalWeeks: value.round()),
                          );
                          if (mounted) {
                            setState(() => _draftTotalWeeks = null);
                          }
                        },
                      ),
                    ),
                    Text(
                      '${totalWeeks.round()} 周',
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStartDate(AppState state) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: state.semester.startDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
      helpText: '选择第 1 周周一',
    );
    if (picked == null) {
      return;
    }
    final DateTime monday = Semester.mondayOf(picked);
    await state.updateSemester(state.semester.copyWith(startDate: monday));
    if (!mounted) {
      return;
    }
    if (picked.weekday != DateTime.monday) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已自动对齐到所选日期所在周的周一')));
    }
  }
}
