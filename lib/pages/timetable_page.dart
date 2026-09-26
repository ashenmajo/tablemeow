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

/// 课表页：周视图，左右滑动切换周次，点击课程块查看详情。
class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  /// 每一周是 PageView 的一页，左右滑动有跟手的切换动画。
  PageController? _pageController;

  static const Duration _switchDuration = Duration(milliseconds: 260);
  static const Curve _switchCurve = Curves.easeOutCubic;

  /// 跨周太多时直接跳过去，不然要连翻好几页。
  static const int _jumpThreshold = 3;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final PageController? controller = _pageController;
    // 课表还没建出来（数据还在读）时不要在这里创建控制器：
    // 那会把「第 1 周」当成初始页，等数据读完就停在第一周不动了。
    if (controller == null ||
        !controller.hasClients ||
        controller.page == null) {
      return;
    }
    _syncPage(AppScope.of(context), controller);
  }

  /// 让 PageView 跟上 [AppState.selectedWeek]。
  ///
  /// 由滑动本身触发的周次变化此时页码已经一致，不会再动。
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

  /// 周次 → PageView 页码（都从 0 开始）。
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
    // 控制器在这里（马上要建 PageView 时）才创建，初始页就是当前显示的那一周。
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

  /// 该周实际渲染的节次：按最后一节课裁剪，避免出现大片空白。
  static List<PeriodTime> _visiblePeriods(AppState state, int week) {
    final int count = state.timetable.visiblePeriodCount(week);
    return state.semester.periods.take(count).toList();
  }
}
