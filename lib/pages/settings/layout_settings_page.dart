//layout_setting_page.dart
//该文件是布局设置页
//可以按照偏好修改课表UI

import 'package:flutter/material.dart';

import '../../data/demo_timetable.dart';
import '../../models/course_session.dart';
import '../../models/period_time.dart';
import '../../models/timetable_style.dart';
import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';
import '../../widgets/timetable_grid.dart';
import '../../widgets/timetable_style_sections.dart';

class LayoutSettingsPage extends StatefulWidget {
  const LayoutSettingsPage({super.key});

  @override
  State<LayoutSettingsPage> createState() => _LayoutSettingsPageState();
}

class _LayoutSettingsPageState extends State<LayoutSettingsPage> {
  late final ScrollController _scrollController;
  bool _showFloatingPreview = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final bool shouldShow =
        _scrollController.hasClients && _scrollController.offset > 250;
    if (shouldShow != _showFloatingPreview && mounted) {
      setState(() => _showFloatingPreview = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('布局与尺寸')),
      body: Stack(
        children: <Widget>[
          PageScaffold(
            controller: _scrollController,
            description: '格子大小、字号、行距与显示哪些结构。',
            children: <Widget>[
              SectionCard(
                title: '实时预览',
                icon: Icons.preview_outlined,
                child: _LayoutPreview(state: state),
              ),
              SectionCard(
                title: '布局与尺寸',
                icon: Icons.tune,
                child: TimetableLayoutSection(
                  style: state.style,
                  onChanged: state.updateStyle,
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: IgnorePointer(
              ignoring: !_showFloatingPreview,
              child: ExcludeSemantics(
                excluding: !_showFloatingPreview,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  opacity: _showFloatingPreview ? 1 : 0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    scale: _showFloatingPreview ? 1 : 0.96,
                    alignment: Alignment.topCenter,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            final double width = (constraints.maxWidth * 0.86)
                                .clamp(0, 336);
                            return Center(
                              child: SizedBox(
                                width: width,
                                child: Material(
                                  key: const ValueKey<String>(
                                    'layout-preview-floating',
                                  ),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLow,
                                  elevation: 8,
                                  shadowColor: Colors.black54,
                                  borderRadius: BorderRadius.circular(16),
                                  clipBehavior: Clip.none,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: _LayoutPreview(
                                      state: state,
                                      floating: true,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayoutPreview extends StatelessWidget {
  const _LayoutPreview({required this.state, this.floating = false});

  final AppState state;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final int periodCount = floating ? 2 : 3;
    final int dayCount = floating ? 3 : 4;
    final List<PeriodTime> periods = state.semester.periods
        .take(periodCount)
        .toList();
    final List<CourseSession> current = state.selectedWeekSessions
        .where(
          (CourseSession session) =>
              session.startPeriod <= periods.length &&
              session.endPeriod <= periods.length &&
              session.weekday <= dayCount,
        )
        .toList();
    final List<CourseSession> sessions = current.isNotEmpty
        ? current
        : demoCourseSessions()
              .where(
                (CourseSession session) =>
                    session.startPeriod <= periods.length &&
                    session.endPeriod <= periods.length &&
                    session.weekday <= dayCount &&
                    session.occursInWeek(state.selectedWeek),
              )
              .toList();
    final ThemeData theme = Theme.of(context);
    final double cellHeight = state.style.autoCellHeight
        ? TimetableStyle.minAutoCellHeight
        : state.style.cellHeight;
    final double periodWidth = state.style.showPeriodColumn
        ? state.style.periodColumnWidth
        : 0;
    final double naturalWidth = periodWidth + state.style.dayWidth * dayCount;
    final double naturalHeight =
        state.style.headerHeight + cellHeight * periodCount;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(
        width: double.infinity,
        key: floating
            ? const ValueKey<String>('layout-preview-floating-content')
            : const ValueKey<String>('layout-preview'),
        height: floating ? 138 : 218,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: SizedBox(
            width: naturalWidth,
            height: naturalHeight,
            child: IgnorePointer(
              child: TimetableGrid(
                semester: state.semester,
                week: state.selectedWeek,
                sessions: sessions,
                periods: periods,
                now: state.now,
                style: state.style,
                visibleDayCount: dayCount,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
