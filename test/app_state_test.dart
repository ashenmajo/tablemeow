import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/data/demo_timetable.dart';
import 'package:tablemeow/data/timetable_storage.dart';
import 'package:tablemeow/models/course_session.dart';
import 'package:tablemeow/models/semester.dart';
import 'package:tablemeow/models/timetable.dart';
import 'package:tablemeow/state/app_state.dart';

void main() {
  // 2026-03-11 是周三，落在第 2 周。
  final DateTime fixedNow = DateTime(2026, 3, 11, 10, 0);

  AppState buildState(MemoryTimetableStorage storage) =>
      AppState(storage: storage, clock: () => fixedNow);

  test('读取旧课表时会洗掉课程名里的重复学时说明', () async {
    final MemoryTimetableStorage storage = MemoryTimetableStorage(
      Timetable(
        semester: Semester(startDate: DateTime(2026, 3, 9), totalWeeks: 20),
        sessions: <CourseSession>[
          CourseSession(
            name: '面向对象程序设计及实践 B-----------------'
                '面向对象程序设计及实践B(理论:32,实践:16)',
            weekday: 1,
            startPeriod: 3,
            endPeriod: 4,
            weeks: <int>[2, 3, 4, 5],
            teacher: '李朝鹏',
            location: '专业五机房（一）',
          ),
        ],
      ).toJson(),
    );
    final AppState state = buildState(storage);

    await state.load();

    expect(state.sessions.single.name, '面向对象程序设计及实践 B');
    expect(state.sessions.single.location, '专业五机房（一）');
  });

  test('首次加载时给出默认学期并把选中周对齐到本周', () async {
    final MemoryTimetableStorage storage = MemoryTimetableStorage();
    final AppState state = buildState(storage);

    await state.load();

    expect(state.isLoaded, isTrue);
    expect(state.sessions, isEmpty);
    expect(state.semester.startDate, DateTime(2026, 3, 9));
    expect(state.currentWeek, 1);
    expect(state.selectedWeek, 1);
  });

  test('导入后写入存储，重新加载可以还原', () async {
    final MemoryTimetableStorage storage = MemoryTimetableStorage();
    final AppState state = buildState(storage);
    await state.load();

    await state.importSessions(demoCourseSessions());

    expect(state.sessions, isNotEmpty);
    expect(storage.json, isNotNull);

    final AppState reloaded = buildState(storage);
    await reloaded.load();
    expect(reloaded.sessions, hasLength(state.sessions.length));
    expect(reloaded.sessions.first.name, state.sessions.first.name);
  });

  test('切换周次会被限制在学期范围内', () async {
    final AppState state = buildState(MemoryTimetableStorage());
    await state.load();
    await state.importSessions(demoCourseSessions());

    state.shiftWeek(-10);
    expect(state.selectedWeek, 1);

    state.selectWeek(5);
    expect(state.selectedWeek, 5);
    expect(state.isViewingCurrentWeek, isFalse);

    state.goToCurrentWeek();
    expect(state.isViewingCurrentWeek, isTrue);
  });

  test('修改学期设置后周次选择保持在有效范围', () async {
    final AppState state = buildState(MemoryTimetableStorage());
    await state.load();
    state.selectWeek(12);

    await state.updateSemester(state.semester.copyWith(totalWeeks: 8));

    expect(state.semester.totalWeeks, 8);
    expect(state.selectedWeek, 8);
  });

  test('清空课表后保留学期设置', () async {
    final AppState state = buildState(MemoryTimetableStorage());
    await state.load();
    await state.updateSemester(
      state.semester.copyWith(totalWeeks: 18, showWeekend: true),
    );
    await state.importSessions(demoCourseSessions());

    await state.clearSessions();

    expect(state.sessions, isEmpty);
    expect(state.semester.totalWeeks, 18);
    expect(state.semester.showWeekend, isTrue);
  });

  test('导入的课程可以按周次查询', () async {
    final AppState state = buildState(MemoryTimetableStorage());
    await state.load();
    await state.importSessions(<CourseSession>[
      CourseSession(
        name: '操作系统',
        weekday: 3,
        startPeriod: 5,
        endPeriod: 6,
        weeks: <int>[1, 2, 3],
      ),
    ]);

    expect(state.selectedWeekSessions, hasLength(1));
    expect(state.selectedWeekSessions.single.name, '操作系统');
  });
}
