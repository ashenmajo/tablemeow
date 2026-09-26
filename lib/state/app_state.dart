import 'package:flutter/foundation.dart';

import '../data/jwxt/jwxt_course_parser.dart';
import '../data/timetable_storage.dart';
import '../models/course_session.dart';
import '../models/semester.dart';
import '../models/timetable.dart';
import '../models/timetable_style.dart';
import '../navigation/app_destination.dart';

/// 应用状态：持有课表数据、当前选中的周次，并负责持久化。
class AppState extends ChangeNotifier {
  AppState({required this.storage, DateTime Function()? clock})
    : clock = clock ?? DateTime.now;

  /// 课表持久化实现。
  final TimetableStorage storage;

  /// 时间来源，测试可注入固定时间。
  final DateTime Function() clock;

  Timetable _timetable = Timetable.empty();
  bool _isLoaded = false;
  int _selectedWeek = 1;
  AppTab _selectedTab = AppTab.timetable;

  /// 底部导航当前选中的页面，页面之间可以互相跳转。
  AppTab get selectedTab => _selectedTab;

  Timetable get timetable => _timetable;

  Semester get semester => _timetable.semester;

  /// 课表外观设置。
  TimetableStyle get style => _timetable.style;

  List<CourseSession> get sessions => _timetable.sessions;

  /// 是否已经完成首次读取。
  bool get isLoaded => _isLoaded;

  /// 课表当前显示的周次。
  int get selectedWeek => _selectedWeek;

  /// 当前时间（可注入，便于测试）。
  DateTime get now => clock();

  /// 今天属于第几周，可能落在学期之外。
  int get currentWeek => semester.weekOfDate(now);

  /// 当前显示的周次是不是「本周」。
  bool get isViewingCurrentWeek => _selectedWeek == currentWeek;

  /// 当前显示周的周一。
  DateTime get selectedWeekStart => semester.weekStart(_selectedWeek);

  /// 当前显示周的课程。
  List<CourseSession> get selectedWeekSessions =>
      _timetable.sessionsOfWeek(_selectedWeek);

  /// 读取本地课表，首次启动时给出一份默认学期设置。
  Future<void> load() async {
    Timetable timetable = Timetable.empty(today: now);
    final Map<String, dynamic>? raw = await storage.readJson();
    if (raw != null) {
      try {
        timetable = _withCleanNames(Timetable.fromJson(raw));
      } catch (_) {
        // 数据结构不兼容时退回默认设置，避免应用无法启动。
        timetable = Timetable.empty(today: now);
      }
    }
    _applyTimetable(timetable);
    _isLoaded = true;
    notifyListeners();
  }

  /// 旧版本导入时课程名可能带着重复的学时说明，读取时顺手洗一遍，
  /// 这样不重新导入也能修正已有的课表。
  static Timetable _withCleanNames(Timetable timetable) {
    final List<CourseSession> cleaned = <CourseSession>[
      for (final CourseSession session in timetable.sessions)
        session.copyWith(name: JwxtCourseParser.cleanCourseName(session.name)),
    ];
    return timetable.copyWith(sessions: List<CourseSession>.unmodifiable(cleaned));
  }

  /// 用导入结果整体替换课表。
  ///
  /// [semester] 为空时沿用当前学期设置，导入教务数据时通常保持原设置。
  Future<void> importSessions(
    List<CourseSession> sessions, {
    Semester? semester,
  }) async {
    _applyTimetable(
      Timetable(
        semester: semester ?? _timetable.semester,
        sessions: List<CourseSession>.unmodifiable(sessions),
      ),
      keepSelectedWeek: true,
    );
    await _persist();
    notifyListeners();
  }

  /// 更新学期设置。
  Future<void> updateSemester(Semester semester) async {
    _applyTimetable(
      Timetable(semester: semester, sessions: _timetable.sessions),
      keepSelectedWeek: true,
    );
    await _persist();
    notifyListeners();
  }

  /// 更新课表外观（格子尺寸、配色、信息显示与主题）。
  ///
  /// 先改内存并通知界面、再落盘，这样拖动滑块时能立刻看到效果。
  Future<void> updateStyle(TimetableStyle style) async {
    _applyTimetable(_timetable.copyWith(style: style), keepSelectedWeek: true);
    notifyListeners();
    await _persist();
  }

  /// 给某一门课单独指定颜色（`null` 表示恢复跟随配色方案）。
  Future<void> setCourseColor(String courseName, int? argb) =>
      updateStyle(_timetable.style.withCourseColor(courseName, argb));

  /// 给某一门课设置别名（空字符串表示恢复原名）。
  Future<void> setCourseAlias(String courseName, String? alias) =>
      updateStyle(_timetable.style.withCourseAlias(courseName, alias));

  /// 清空课表（保留学期设置与节次时间）。
  Future<void> clearSessions() async {
    _applyTimetable(
      Timetable(semester: _timetable.semester),
      keepSelectedWeek: true,
    );
    await _persist();
    notifyListeners();
  }

  void selectWeek(int week) {
    final int clamped = week.clamp(1, semester.totalWeeks);
    if (clamped == _selectedWeek) {
      return;
    }
    _selectedWeek = clamped;
    notifyListeners();
  }

  /// 切换底部导航页面。
  void openTab(AppTab tab) {
    if (tab == _selectedTab) {
      return;
    }
    _selectedTab = tab;
    notifyListeners();
  }

  /// 左右滑动/按钮切换周次。
  void shiftWeek(int delta) => selectWeek(_selectedWeek + delta);

  /// 回到本周。
  void goToCurrentWeek() => selectWeek(currentWeek);

  /// 重新计算依赖「当前时间」的界面（时间线、今日课程）。
  void refresh() => notifyListeners();

  void _applyTimetable(Timetable timetable, {bool keepSelectedWeek = false}) {
    _timetable = timetable;
    if (!keepSelectedWeek) {
      _selectedWeek = currentWeek.clamp(1, timetable.semester.totalWeeks);
    } else {
      _selectedWeek = _selectedWeek.clamp(1, timetable.semester.totalWeeks);
    }
  }

  Future<void> _persist() => storage.writeJson(_timetable.toJson());
}
