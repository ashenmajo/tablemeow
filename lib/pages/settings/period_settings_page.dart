///period_setting_page.dart
///该文件是节次时间设置页
///提供了自动分配时间，测试的时候发现有些课间、课长没有统一的导致后面的时间分配出错，所以提供了手动修改时间
library;

import 'package:flutter/material.dart';

import '../../models/period_time.dart';
import '../../models/semester.dart';
import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../utils/date_format.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';

class PeriodSettingsPage extends StatefulWidget {
  const PeriodSettingsPage({super.key});

  @override
  State<PeriodSettingsPage> createState() => _PeriodSettingsPageState();
}

class _PeriodSettingsPageState extends State<PeriodSettingsPage> {
  static const int _minLesson = 30;
  static const int _maxLesson = 60;
  static const int _maxBreak = 30;

  TimeOfDay? _morning;
  TimeOfDay? _afternoon;
  TimeOfDay? _evening;
  double _lesson = 45;
  double _rest = 10;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) {
      return;
    }
    _initialised = true;

    final List<PeriodTime> periods = AppScope.of(context).semester.periods;
    _morning = _firstStartOf(periods, PeriodSession.morning, 8 * 60);
    _afternoon = _firstStartOf(periods, PeriodSession.afternoon, 14 * 60);
    _evening = _firstStartOf(periods, PeriodSession.evening, 19 * 60);
    if (periods.isNotEmpty) {
      final PeriodTime first = periods.first;
      _lesson =
          (PeriodTime.minuteOf(first.end) - PeriodTime.minuteOf(first.start))
              .clamp(_minLesson, _maxLesson)
              .toDouble();
    }
    if (periods.length > 1) {
      _rest =
          (PeriodTime.minuteOf(periods[1].start) -
                  PeriodTime.minuteOf(periods.first.end))
              .clamp(0, _maxBreak)
              .toDouble();
    }
  }

  static TimeOfDay _firstStartOf(
    List<PeriodTime> periods,
    PeriodSession session,
    int fallbackMinute,
  ) {
    for (final PeriodTime period in periods) {
      if (period.session == session) {
        return _timeOf(period.start);
      }
    }
    return _timeOf(PeriodTime.clockOf(fallbackMinute));
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final ThemeData theme = Theme.of(context);
    final bool hasEvening = state.semester.periods.any(
      (PeriodTime period) => period.session == PeriodSession.evening,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('节次时间')),
      body: PageScaffold(
        children: <Widget>[
          SectionCard(
            title: '自动调整',
            icon: Icons.auto_fix_high_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _TimeRow(
                  label: '上午开始',
                  value: _morning!,
                  onChanged: (TimeOfDay value) =>
                      setState(() => _morning = value),
                ),
                _TimeRow(
                  label: '下午开始',
                  value: _afternoon!,
                  onChanged: (TimeOfDay value) =>
                      setState(() => _afternoon = value),
                ),
                if (hasEvening)
                  _TimeRow(
                    label: '晚上开始',
                    value: _evening!,
                    onChanged: (TimeOfDay value) =>
                        setState(() => _evening = value),
                  ),
                const SizedBox(height: 8),
                _SliderRow(
                  label: '每节时长',
                  value: '${_lesson.round()} 分钟',
                  child: Slider(
                    value: _lesson,
                    min: _minLesson.toDouble(),
                    max: _maxLesson.toDouble(),
                    divisions: (_maxLesson - _minLesson) ~/ 5,
                    label: '${_lesson.round()} 分钟',
                    onChanged: (double value) =>
                        setState(() => _lesson = value),
                  ),
                ),
                _SliderRow(
                  label: '课间休息',
                  value: '${_rest.round()} 分钟',
                  child: Slider(
                    value: _rest,
                    min: 0,
                    max: _maxBreak.toDouble(),
                    divisions: _maxBreak ~/ 5,
                    label: '${_rest.round()} 分钟',
                    onChanged: (double value) => setState(() => _rest = value),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _apply(state),
                  icon: const Icon(Icons.playlist_add_check, size: 18),
                  label: const Text('按上面参数重排节次'),
                ),
                const SizedBox(height: 6),
                Text(
                  '会覆盖下面每一节的时间，节数不变。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SectionCard(
            title: '每节课的时间',
            subtitle: '点击任意一节可以单独修改',
            icon: Icons.schedule_outlined,
            child: Column(
              children: <Widget>[
                for (final PeriodTime period in state.semester.periods)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      child: Text(
                        '${period.index}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    title: Text(period.label),
                    trailing: Text(
                      '${period.start} - ${period.end}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    onTap: () => _editPeriod(context, state, period),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _apply(AppState state) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final List<PeriodTime> periods = Semester.autoPeriods(
      state.semester.periods,
      morningStart: _minutes(_morning!),
      afternoonStart: _minutes(_afternoon!),
      eveningStart: _minutes(_evening!),
      lessonMinutes: _lesson.round(),
      breakMinutes: _rest.round(),
    );
    await state.updateSemester(state.semester.copyWith(periods: periods));
    messenger.showSnackBar(const SnackBar(content: Text('节次时间已重排')));
  }

  Future<void> _editPeriod(
    BuildContext context,
    AppState state,
    PeriodTime period,
  ) async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: _timeOf(period.start),
      helpText: '第 ${period.index} 节开始时间',
    );
    if (start == null || !context.mounted) {
      return;
    }
    final TimeOfDay? end = await showTimePicker(
      context: context,
      initialTime: _timeOf(period.end),
      helpText: '第 ${period.index} 节结束时间',
    );
    if (end == null) {
      return;
    }
    final List<PeriodTime> periods = <PeriodTime>[
      for (final PeriodTime item in state.semester.periods)
        item.index == period.index
            ? item.copyWith(start: _clockText(start), end: _clockText(end))
            : item,
    ];
    await state.updateSemester(state.semester.copyWith(periods: periods));
  }

  static int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static TimeOfDay _timeOf(String hhmm) {
    final int minute = PeriodTime.minuteOf(hhmm);
    return TimeOfDay(hour: minute ~/ 60, minute: minute % 60);
  }

  static String _clockText(TimeOfDay time) =>
      '${twoDigits(time.hour)}:${twoDigits(time.minute)}';
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: value,
          helpText: label,
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.child,
  });

  final String label;
  final String value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        child,
      ],
    );
  }
}
