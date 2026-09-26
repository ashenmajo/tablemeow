import 'package:flutter/material.dart';

import '../models/course_session.dart';
import '../models/semester.dart';
import '../models/timetable.dart';
import '../models/timetable_style.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/course_palette.dart';
import '../utils/date_format.dart';

/// 显示课程详情（底部弹窗）。
///
/// 除了时间地点教师，还能给这门课单独指定颜色与别名，
/// 按课程名保存，下次导入依然生效。
Future<void> showCourseDetailSheet(
  BuildContext context, {
  required CourseSession session,
  required Semester semester,
  required int week,
}) {
  final DateTime day = semester.dateOf(week, session.weekday);
  final PeriodTimeRange? range = Timetable(semester: semester)
      .rangeOf(session, day);

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      final AppState state = AppScope.of(context);
      final TimetableStyle style = state.style;
      final ThemeData theme = Theme.of(context);
      final Color accent = CoursePalette.onSurface(
        session.name,
        style,
        theme.colorScheme,
      );

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                style.nameFor(session.name),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (style.nameFor(session.name) != session.name)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    session.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _InfoChip(
                    icon: Icons.event_available_outlined,
                    label:
                        '${semester.weekdayName(session.weekday)} ${session.periodLabel}',
                    accent: accent,
                  ),
                  if (range != null)
                    _InfoChip(
                      icon: Icons.schedule_outlined,
                      label:
                          '${formatClock(range.start)} - ${formatClock(range.end)}',
                      accent: accent,
                    ),
                  if (session.location.isNotEmpty)
                    _InfoChip(
                      icon: Icons.place_outlined,
                      label: session.location,
                      accent: accent,
                    ),
                  if (session.teacher.isNotEmpty)
                    _InfoChip(
                      icon: Icons.person_outline,
                      label: style.teacherFor(session.teacher),
                      accent: accent,
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _DetailRow(
                icon: Icons.date_range_outlined,
                label: '上课周次',
                value: session.weeksLabel,
              ),
              _DetailRow(
                icon: Icons.today_outlined,
                label: '本周日期',
                value:
                    '${formatMonthDay(day)} ${semester.weekdayName(session.weekday)}',
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              _buildColorRow(context, state, style, session),
              _buildAliasRow(context, state, style, session),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

/// 这门课的颜色：只显示一行，点开后才让你挑。
Widget _buildColorRow(
  BuildContext context,
  AppState state,
  TimetableStyle style,
  CourseSession session,
) {
  final ThemeData theme = Theme.of(context);
  final int? custom = style.courseColors[session.name];
  final Color current = custom == null
      ? CoursePalette.surface(session.name, style, theme.colorScheme)
      : Color(custom);

  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: current,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
    ),
    title: const Text('课程颜色'),
    subtitle: Text(
      custom == null ? '跟随主题色' : '已单独指定',
      style: theme.textTheme.bodySmall,
    ),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => _pickColor(context, state, style, session),
  );
}

/// 颜色选择弹窗：选一个颜色，或恢复成跟随主题色。
Future<void> _pickColor(
  BuildContext context,
  AppState state,
  TimetableStyle style,
  CourseSession session,
) async {
  final int? custom = style.courseColors[session.name];

  final int? result = await showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      final ThemeData theme = Theme.of(context);
      return AlertDialog(
        title: const Text('课程颜色'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                for (final Color color
                    in CoursePalette.swatchesFor(theme.colorScheme))
                  _ColorDot(
                    color: color,
                    selected: custom == color.toARGB32(),
                    onTap: () =>
                        Navigator.of(context).pop(color.toARGB32()),
                  ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          if (custom != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(_resetColor),
              child: const Text('跟随主题色'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      );
    },
  );
  if (result == null) {
    return;
  }
  await state.setCourseColor(
    session.name,
    result == _resetColor ? null : result,
  );
}

/// 用 `-1` 表示「恢复跟随主题色」。
const int _resetColor = -1;

/// 给这门课起一个别名（课表上显示别名）。
Widget _buildAliasRow(
  BuildContext context,
  AppState state,
  TimetableStyle style,
  CourseSession session,
) {
  final ThemeData theme = Theme.of(context);
  final String? alias = style.courseAliases[session.name];

  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      Icons.drive_file_rename_outline,
      color: theme.colorScheme.onSurfaceVariant,
    ),
    title: const Text('课表上显示的名字'),
    subtitle: Text(
      alias == null ? '当前用课程全名' : '别名：$alias',
      style: theme.textTheme.bodySmall,
    ),
    trailing: const Icon(Icons.edit_outlined, size: 18),
    onTap: () => _editAlias(context, state, session, alias),
  );
}

Future<void> _editAlias(
  BuildContext context,
  AppState state,
  CourseSession session,
  String? current,
) async {
  final String? result = await showDialog<String>(
    context: context,
    builder: (BuildContext context) => _AliasDialog(
      initial: current ?? session.name,
      fallback: session.name,
    ),
  );
  if (result == null) {
    return;
  }
  await state.setCourseAlias(session.name, result);
}

/// 改名弹窗。
///
/// 输入框控制器由弹窗自己持有并销毁：如果在 `showDialog` 返回后立刻
/// dispose，弹窗还在退场动画里挂着，会触发 `_dependents.isEmpty` 断言。
class _AliasDialog extends StatefulWidget {
  const _AliasDialog({required this.initial, required this.fallback});

  final String initial;
  final String fallback;

  @override
  State<_AliasDialog> createState() => _AliasDialogState();
}

class _AliasDialogState extends State<_AliasDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('显示名称'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        //decoration: InputDecoration(hintText: widget.fallback),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

/// 可选颜色的圆点。
class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: selected
            ? Icon(
                Icons.check,
                size: 16,
                color: ThemeData.estimateBrightnessForColor(color) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              )
            : null,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 6),
          // 教室、教师这类字段可能很长，让它换行显示完整信息，
          // 不要用省略号截断。
          Flexible(
            child: Text(
              label,
              softWrap: true,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
