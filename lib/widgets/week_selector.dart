import 'package:flutter/material.dart';

import '../models/semester.dart';
import '../utils/date_format.dart';

class WeekSelector extends StatelessWidget {
  const WeekSelector({
    super.key,
    required this.semester,
    required this.week,
    required this.currentWeek,
    required this.onWeekSelected,
    required this.onStep,
    required this.onBackToCurrentWeek,
  });

  final Semester semester;
  final int week;

  final int currentWeek;

  final ValueChanged<int> onWeekSelected;
  final ValueChanged<int> onStep;
  final VoidCallback onBackToCurrentWeek;

  bool get _isCurrentWeek => week == currentWeek;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final DateTime start = semester.weekStart(week);
    final DateTime end = start.add(const Duration(days: 6));

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 8, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: '上一周',
            onPressed: week > 1 ? () => onStep(-1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showWeekPicker(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('第 $week 周', style: theme.textTheme.titleMedium),
                        if (_isCurrentWeek) ...<Widget>[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              // 深底 + onPrimary（亮色下就是白字），
                              // 想要白字就得让底色跟着变深。
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '本周',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 2),
                        Icon(
                          Icons.expand_more,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateRange(start, end),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: '下一周',
            onPressed: week < semester.totalWeeks ? () => onStep(1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
          if (!_isCurrentWeek)
            TextButton(onPressed: onBackToCurrentWeek, child: const Text('本周')),
        ],
      ),
    );
  }

  Future<void> _showWeekPicker(BuildContext context) async {
    final int? selected = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择周次'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.6,
              ),
              itemCount: semester.totalWeeks,
              itemBuilder: (BuildContext context, int index) {
                final int week = index + 1;
                final bool isSelected = week == this.week;
                final bool isCurrent = week == currentWeek;
                return FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(week),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 40),
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('$week'),
                      if (isCurrent)
                        Text(
                          '本周',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isSelected
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onPrimary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                              ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      onWeekSelected(selected);
    }
  }
}
