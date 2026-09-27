import 'package:flutter/foundation.dart';

import '../data/jwxt/jwxt_course_parser.dart';
import '../data/timetable_storage.dart';
import '../models/course_session.dart';
import '../models/semester.dart';
import '../models/timetable.dart';
import '../models/timetable_style.dart';
import '../navigation/app_destination.dart';

class AppState extends ChangeNotifier {
  AppState({required this.storage, DateTime Function()? clock})
    : clock = clock ?? DateTime.now;

  final TimetableStorage storage;

  final DateTime Function() clock;

  Timetable _timetable = Timetable.empty();
  bool _isLoaded = false;
  int _selectedWeek = 1;
  AppTab _selectedTab = AppTab.timetable;

  AppTab get selectedTab => _selectedTab;

  Timetable get timetable => _timetable;

  Semester get semester => _timetable.semester;

  TimetableStyle get style => _timetable.style;

  List<CourseSession> get sessions => _timetable.sessions;

  bool get isLoaded => _isLoaded;

  int get selectedWeek => _selectedWeek;

  DateTime get now => clock();

  int get currentWeek => semester.weekOfDate(now);

  List<CourseSession> get selectedWeekSessions =>
      _timetable.sessionsOfWeek(_selectedWeek);

  Future<void> load() async {
    Timetable timetable = Timetable.empty(today: now);
    final Map<String, dynamic>? raw = await storage.readJson();
    if (raw != null) {
      try {
        timetable = _withCleanNames(Timetable.fromJson(raw));
      } catch (_) {

        timetable = Timetable.empty(today: now);
      }
    }
    _applyTimetable(timetable);
    _isLoaded = true;
    notifyListeners();
  }

  static Timetable _withCleanNames(Timetable timetable) {
    final List<CourseSession> cleaned = <CourseSession>[
      for (final CourseSession session in timetable.sessions)
        session.copyWith(name: JwxtCourseParser.cleanCourseName(session.name)),
    ];
    return timetable.copyWith(sessions: List<CourseSession>.unmodifiable(cleaned));
  }


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


  Future<void> updateSemester(Semester semester) async {
    _applyTimetable(
      Timetable(semester: semester, sessions: _timetable.sessions),
      keepSelectedWeek: true,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> updateStyle(TimetableStyle style) async {
    _applyTimetable(_timetable.copyWith(style: style), keepSelectedWeek: true);
    notifyListeners();
    await _persist();
  }

  Future<void> setCourseColor(String courseName, int? argb) =>
      updateStyle(_timetable.style.withCourseColor(courseName, argb));

  Future<void> setCourseAlias(String courseName, String? alias) =>
      updateStyle(_timetable.style.withCourseAlias(courseName, alias));

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

  void openTab(AppTab tab) {
    if (tab == _selectedTab) {
      return;
    }
    _selectedTab = tab;
    notifyListeners();
  }

  void shiftWeek(int delta) => selectWeek(_selectedWeek + delta);

  void goToCurrentWeek() => selectWeek(currentWeek);

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
