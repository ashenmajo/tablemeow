//timetable_page.dart
//该文件是课表页

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/course_session.dart';
import '../models/period_time.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../widgets/course_detail_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/timetable_grid.dart';
import '../widgets/week_selector.dart';
import '../pages/import_page.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  PageController? _pageController;

  static const Duration _switchDuration = Duration(milliseconds: 260);
  static const Curve _switchCurve = Curves.easeOutCubic;

  /// 跨周太多时直接跳过去，不然要连翻好几页。
  static const int _jumpThreshold = 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final PageController? controller = _pageController;
    // 课表还没建出来时不能在这里创建控制器，数据还没读完，不然会把第 1 周当成初始页，等数据读完就停在第一周不动了。
    if (controller == null ||
        !controller.hasClients ||
        controller.page == null) {
      return;
    }
    _syncPage(AppScope.of(context), controller);
  }

  void _syncPage(AppState state, PageController controller) {
    final int target = _pageOf(state, state.selectedWeek);
    final int current = controller.page!.round();
    if (current == target) {
      return;
    }
    if ((current - target).abs() > _jumpThreshold) {
      controller.jumpToPage(target);
    } else {
      controller.animateToPage(
        target,
        duration: _switchDuration,
        curve: _switchCurve,
      );
    }
  }

  static void _open(BuildContext context, Widget page) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) => page));
  }

  static int _pageOf(AppState state, int week) =>
      (week - 1).clamp(0, math.max(state.semester.totalWeeks - 1, 0));

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('课程表'),
        actions: <Widget>[
          IconButton(
            onPressed: () => _open(context, const ImportPage()),
            tooltip: '导入课表',
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, AppState state) {
    if (!state.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.timetable.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.calendar_view_week_outlined,
          title: '还没有课表数据',
          message: '打开学校登录页导入课表后，这里会显示每周的课程。',
          actionLabel: '去导入课表',
          actionIcon: Icons.cloud_download_outlined,
          onAction: () => _open(context, const ImportPage()),
        ),
      );
    }
    final PageController controller = _pageController ??= PageController(
      initialPage: _pageOf(state, state.selectedWeek),
    );
    return Column(
      children: <Widget>[
        if (state.style.showWeekSelector) ...<Widget>[
          WeekSelector(
            semester: state.semester,
            week: state.selectedWeek,
            currentWeek: state.currentWeek,
            onWeekSelected: state.selectWeek,
            onStep: state.shiftWeek,
            onBackToCurrentWeek: state.goToCurrentWeek,
          ),
          const Divider(height: 1),
        ],
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemCount: state.semester.totalWeeks,
            onPageChanged: (int index) => state.selectWeek(index + 1),
            itemBuilder: (BuildContext context, int index) =>
                _buildWeek(context, state, index + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildWeek(BuildContext context, AppState state, int week) {
    return TimetableGrid(
      semester: state.semester,
      week: week,
      sessions: state.timetable.sessionsOfWeek(week),
      periods: _visiblePeriods(state, week),
      now: state.now,
      style: state.style,
      onSessionTap: (CourseSession session) => showCourseDetailSheet(
        context,
        session: session,
        semester: state.semester,
        week: week,
      ),
    );
  }

  /// 这里按最后一节课裁剪，不然课表和导航栏之间会出现大片空白。
  static List<PeriodTime> _visiblePeriods(AppState state, int week) {
    final int count = state.timetable.visiblePeriodCount(week);
    return state.semester.periods.take(count).toList();
  }
}
