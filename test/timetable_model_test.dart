import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/models/course_session.dart';
import 'package:tablemeow/models/period_time.dart';
import 'package:tablemeow/models/semester.dart';
import 'package:tablemeow/models/timetable.dart';
import 'package:tablemeow/models/timetable_style.dart';

void main() {
  final Semester semester = Semester(
    startDate: DateTime(2026, 3, 2),
    totalWeeks: 20,
  );

  group('学期周次换算', () {
    test('起始日所在周为第 1 周', () {
      expect(semester.weekOfDate(DateTime(2026, 3, 2)), 1);
      expect(semester.weekOfDate(DateTime(2026, 3, 8)), 1);
      expect(semester.weekOfDate(DateTime(2026, 3, 9)), 2);
      expect(semester.weekOfDate(DateTime(2026, 3, 15)), 2);
    });

    test('星期几的日期推算', () {
      expect(semester.dateOf(1, 1), DateTime(2026, 3, 2));
      expect(semester.dateOf(1, 7), DateTime(2026, 3, 8));
      expect(semester.dateOf(2, 3), DateTime(2026, 3, 11));
    });

    test('周一取整', () {
      expect(Semester.mondayOf(DateTime(2026, 3, 11)), DateTime(2026, 3, 9));
      expect(Semester.mondayOf(DateTime(2026, 3, 9)), DateTime(2026, 3, 9));
      expect(Semester.mondayOf(DateTime(2026, 3, 8)), DateTime(2026, 3, 2));
    });

    test('默认显示周末，也可以关掉', () {
      // 周末没课也要保留两列，默认就是 7 列。
      expect(semester.showWeekend, isTrue);
      expect(semester.weekdayCount, 7);
      expect(semester.copyWith(showWeekend: false).weekdayCount, 5);
    });

    test('节次按最后一节课裁剪，并用最少节次兜底', () {
      final Timetable shortDay = Timetable(
        semester: semester,
        sessions: <CourseSession>[
          CourseSession(
            name: '大学物理',
            weekday: 4,
            startPeriod: 1,
            endPeriod: 2,
            weeks: <int>[1],
          ),
        ],
      );
      final Timetable lateNight = Timetable(
        semester: semester,
        sessions: <CourseSession>[
          CourseSession(
            name: '晚自习',
            weekday: 4,
            startPeriod: 11,
            endPeriod: 12,
            weeks: <int>[1],
          ),
        ],
      );

      // 只有 1-2 节有课时仍显示 8 节。
      expect(shortDay.visiblePeriodCount(1), 8);
      // 第 12 节有课时显示到 12 节，且不超过配置的节次数量。
      expect(lateNight.visiblePeriodCount(1), 12);
      expect(
        lateNight.visiblePeriodCount(1) <= semester.periods.length,
        isTrue,
      );
      // 其他周没有课时按兜底节次显示。
      expect(shortDay.visiblePeriodCount(5), 8);
    });
  });

  group('课表查询', () {
    final Timetable timetable = Timetable(
      semester: semester,
      sessions: <CourseSession>[
        CourseSession(
          name: '高等数学',
          weekday: 1,
          startPeriod: 1,
          endPeriod: 2,
          weeks: <int>[1, 2, 3],
        ),
        CourseSession(
          name: '大学英语',
          weekday: 1,
          startPeriod: 3,
          endPeriod: 4,
          weeks: <int>[2, 4],
        ),
        CourseSession(
          name: '数据结构',
          weekday: 3,
          startPeriod: 5,
          endPeriod: 6,
          weeks: <int>[1, 2, 3],
        ),
      ],
    );

    test('按周与星期筛选并排序', () {
      expect(
        timetable
            .sessionsAt(week: 1, weekday: 1)
            .map((CourseSession s) => s.name),
        <String>['高等数学'],
      );
      expect(
        timetable
            .sessionsAt(week: 2, weekday: 1)
            .map((CourseSession s) => s.name),
        <String>['高等数学', '大学英语'],
      );
      expect(timetable.sessionsAt(week: 3, weekday: 1), hasLength(1));
    });

    test('按日期取课', () {
      expect(timetable.sessionsOn(DateTime(2026, 3, 2)), hasLength(1));
      expect(timetable.sessionsOn(DateTime(2026, 3, 4)), hasLength(1));
      expect(timetable.sessionsOn(DateTime(2026, 3, 5)), isEmpty);
    });

    test('统计课程门数', () {
      expect(timetable.courseCount, 3);
      expect(timetable.isNotEmpty, isTrue);
    });

    test('下一次上课时间', () {
      // 2026-03-02 是第 1 周周一，第 1-2 节 08:00-09:40。
      expect(
        timetable.nextSessionAfter(DateTime(2026, 3, 2, 7, 30))?.name,
        '高等数学',
      );
      expect(
        timetable.nextSessionAfter(DateTime(2026, 3, 2, 9, 0))?.name,
        '高等数学',
      );
      expect(timetable.nextSessionAfter(DateTime(2026, 3, 2, 10, 0)), isNull);
    });
  });

  group('课表外观设置', () {
    test('默认值可以直接用', () {
      const TimetableStyle style = TimetableStyle.defaults;
      expect(style.autoCellHeight, isTrue);
      expect(style.showGrid, isTrue);
      expect(style.headerHeight, TimetableStyle.defaultHeaderHeight);
      expect(style.courseBlockRadius, TimetableStyle.defaultCourseBlockRadius);
      expect(style.courseTextAlignment, CourseTextAlignment.left);
      expect(style.detailFontSize, lessThan(style.fontSize));
    });

    test('可以往返序列化，越界值会被夹回范围', () {
      const TimetableStyle style = TimetableStyle(
        seedColorValue: 0xFF00695C,
        dayWidth: 72,
        cellHeight: 96,
        fontScale: 1.2,
        lineHeight: CourseLineHeight.relaxed,
        headerHeight: 64,
        periodColumnWidth: 52,
        courseBlockGap: 4,
        courseBlockRadius: 18,
        courseHorizontalPadding: 6,
        courseVerticalPadding: 5,
        courseTextAlignment: CourseTextAlignment.center,
        colorMode: CourseColorMode.custom,
        palette: CoursePaletteKind.morandi,
        textColor: CourseTextColor.dark,
        courseColors: <String, int>{'高等数学': 0xFFD7E3FF},
        courseAliases: <String, String>{'高等数学': '高数'},
        showTeacher: true,
        nameStyle: CourseNameStyle.alias,
        themeMode: AppThemeMode.dark,
        oledBlack: true,
        showGrid: false,
        showHeaderDate: false,
        showPeriodEndTime: false,
        highlightToday: false,
        showCurrentTime: false,
      );
      expect(TimetableStyle.fromJson(style.toJson()), style);
      expect(style.seedColor, const Color(0xFF00695C));

      final TimetableStyle clamped = TimetableStyle.fromJson(<String, dynamic>{
        'dayWidth': 999,
        'cellHeight': -5,
        'fontScale': 9,
        'headerHeight': 999,
        'periodColumnWidth': 1,
        'courseBlockGap': 99,
        'courseBlockRadius': -10,
        'courseHorizontalPadding': 99,
        'courseVerticalPadding': 99,
        'showGrid': false,
      });
      expect(clamped.dayWidth, TimetableStyle.maxDayWidth);
      expect(clamped.cellHeight, 0);
      expect(clamped.fontScale, TimetableStyle.maxFontScale);
      expect(clamped.headerHeight, TimetableStyle.maxHeaderHeight);
      expect(clamped.periodColumnWidth, TimetableStyle.minPeriodColumnWidth);
      expect(clamped.courseBlockGap, TimetableStyle.maxCourseBlockGap);
      expect(clamped.courseBlockRadius, TimetableStyle.minCourseBlockRadius);
      expect(
        clamped.courseHorizontalPadding,
        TimetableStyle.maxCourseHorizontalPadding,
      );
      expect(
        clamped.courseVerticalPadding,
        TimetableStyle.maxCourseVerticalPadding,
      );
    });

    test('老数据的绝对字号会换算成缩放倍数', () {
      final TimetableStyle style = TimetableStyle.fromJson(<String, dynamic>{
        'fontSize': 15,
      });
      expect(style.fontSize, closeTo(15, 0.001));
      expect(style.fontScale, greaterThan(1));
    });

    test('周末开关可以从学期设置迁移过来', () {
      final TimetableStyle style = TimetableStyle.fromJson(
        <String, dynamic>{},
        legacyShowWeekend: false,
      );
      expect(style.showWeekend, isFalse);
    });

    test('别名与单课颜色按课程名保存', () {
      const TimetableStyle style = TimetableStyle(
        nameStyle: CourseNameStyle.alias,
      );
      final TimetableStyle custom = style
          .withCourseAlias('习近平新时代中国特色社会主义思想概论', '习概')
          .withCourseColor('习近平新时代中国特色社会主义思想概论', 0xFFA8E6D0);

      expect(custom.nameFor('习近平新时代中国特色社会主义思想概论'), '习概');
      expect(custom.nameFor('高等数学'), '高等数学');
      expect(custom.courseColors['习近平新时代中国特色社会主义思想概论'], 0xFFA8E6D0);

      // 清空后回到原名与原配色。
      final TimetableStyle cleared = custom
          .withCourseAlias('习近平新时代中国特色社会主义思想概论', '')
          .withCourseColor('习近平新时代中国特色社会主义思想概论', null);
      expect(cleared.courseAliases, isEmpty);
      expect(cleared.courseColors, isEmpty);
    });

    test('只在选了别名模式时才用别名', () {
      final TimetableStyle style = const TimetableStyle().withCourseAlias(
        '高等数学',
        '高数',
      );
      expect(style.nameFor('高等数学'), '高等数学');
      expect(
        style.copyWith(nameStyle: CourseNameStyle.alias).nameFor('高等数学'),
        '高数',
      );
    });

    test('教师职称按开关决定要不要去掉', () {
      const TimetableStyle style = TimetableStyle();
      expect(style.teacherFor('刘湛讲师（高校）'), '刘湛');
      expect(
        style.copyWith(stripTeacherTitle: false).teacherFor('刘湛讲师（高校）'),
        '刘湛讲师（高校）',
      );
    });

    test('行高枚举决定行距', () {
      expect(
        const TimetableStyle(lineHeight: CourseLineHeight.compact)
            .nameLineHeight,
        lessThan(
          const TimetableStyle(lineHeight: CourseLineHeight.relaxed)
              .nameLineHeight,
        ),
      );
    });

    test('教室能放两行就给它两行', () {
      const TimetableStyle style = TimetableStyle();
      // 「专业五机房（一）」这种整段中文的教室也要两行才放得下，
      // 所以不能按「几段」来限制。
      expect(style.lineBudget(160, detailWidgets: 1).detailLines, 2);
      expect(style.lineBudget(80, detailWidgets: 1).detailLines, 2);
      expect(style.lineBudget(46, detailWidgets: 1).detailLines, 1);
      expect(style.lineBudget(160, detailWidgets: 1).nameLines, 8);
      // 没有副信息时高度全给课程名。
      expect(style.lineBudget(160, detailWidgets: 0).detailLines, 0);
      expect(style.lineBudget(160, detailWidgets: 0).nameLines, 9);
      // 地点 + 教师时最多三行副信息。
      expect(style.lineBudget(200, detailWidgets: 2).detailLines, 3);
    });

    test('行数预算永远不会超过格子高度', () {
      for (final double height in <double>[40, 56, 72, 120, 200, 400]) {
        for (final double scale in <double>[0.8, 1, 1.5]) {
          final TimetableStyle style = TimetableStyle(
            fontScale: scale,
            cellHeight: height,
          );
          for (final int widgets in <int>[0, 1, 2]) {
            final ({int detailLines, int nameLines}) budget = style.lineBudget(
              height,
              detailWidgets: widgets,
            );
            final double needed =
                budget.nameLines * style.nameLineHeight +
                budget.detailLines * style.detailLineHeight;
            expect(
              needed,
              lessThanOrEqualTo(height - style.courseVerticalPadding * 2),
              reason: 'height=$height scale=$scale widgets=$widgets',
            );
          }
        }
      }
    });

    test('课表序列化时带上外观设置', () {
      final Timetable original = Timetable(
        semester: semester,
        sessions: const <CourseSession>[],
        style: const TimetableStyle(dayWidth: 64, fontScale: 1.2),
      );
      final Timetable restored = Timetable.fromJson(original.toJson());

      expect(restored.style.dayWidth, 64);
      expect(restored.style.fontScale, 1.2);
    });

    test('旧数据没有 style 字段时退回默认值', () {
      final Map<String, dynamic> legacy = Timetable(
        semester: semester,
        sessions: const <CourseSession>[],
      ).toJson()..remove('style');

      expect(Timetable.fromJson(legacy).style, TimetableStyle.defaults);
    });
  });

  group('自动排节次', () {
    test('按时长与课间把三段分别排开', () {
      const List<PeriodTime> periods = <PeriodTime>[
        PeriodTime(index: 1, start: '08:00', end: '08:45'),
        PeriodTime(index: 2, start: '08:55', end: '09:40'),
        PeriodTime(index: 3, start: '10:00', end: '10:45'),
        PeriodTime(index: 4, start: '10:55', end: '11:40'),
        PeriodTime(index: 5, start: '14:00', end: '14:45'),
        PeriodTime(index: 6, start: '14:55', end: '15:40'),
        PeriodTime(index: 7, start: '19:00', end: '19:45'),
      ];

      final List<PeriodTime> result = Semester.autoPeriods(
        periods,
        morningStart: 8 * 60,
        afternoonStart: 14 * 60,
        eveningStart: 19 * 60,
        lessonMinutes: 45,
        breakMinutes: 10,
      );

      expect(result.map((PeriodTime p) => '${p.start}-${p.end}'), <String>[
        '08:00-08:45',
        '08:55-09:40',
        '09:50-10:35',
        '10:45-11:30',
        '14:00-14:45',
        '14:55-15:40',
        '19:00-19:45',
      ]);
    });

    test('改开始时间只影响对应时段', () {
      const List<PeriodTime> periods = <PeriodTime>[
        PeriodTime(index: 1, start: '08:00', end: '08:45'),
        PeriodTime(index: 2, start: '14:00', end: '14:45'),
      ];

      final List<PeriodTime> result = Semester.autoPeriods(
        periods,
        morningStart: 7 * 60 + 30,
        afternoonStart: 13 * 60,
        eveningStart: 19 * 60,
        lessonMinutes: 40,
        breakMinutes: 5,
      );

      expect(result.first.start, '07:30');
      expect(result.first.end, '08:10');
      expect(result.last.start, '13:00');
      expect(result.last.end, '13:40');
    });

    test('分钟数与时间文本可以互转', () {
      expect(PeriodTime.minuteOf('08:20'), 500);
      expect(PeriodTime.clockOf(500), '08:20');
      expect(PeriodTime.clockOf(23 * 60 + 59), '23:59');
    });

    test('节次按开始时间分到上午 / 下午 / 晚上', () {
      expect(
        const PeriodTime(index: 1, start: '08:00', end: '08:45').session,
        PeriodSession.morning,
      );
      expect(
        const PeriodTime(index: 2, start: '14:00', end: '14:45').session,
        PeriodSession.afternoon,
      );
      expect(
        const PeriodTime(index: 3, start: '19:00', end: '19:45').session,
        PeriodSession.evening,
      );
    });
  });

  group('序列化', () {
    test('课表可往返序列化', () {
      final Timetable original = Timetable(
        semester: semester.copyWith(showWeekend: true),
        sessions: <CourseSession>[
          CourseSession(
            name: '计算机网络',
            weekday: 5,
            startPeriod: 1,
            endPeriod: 2,
            weeks: <int>[1, 3, 5],
            teacher: '张伟',
            location: '教二306',
          ),
        ],
      );

      final Timetable restored = Timetable.fromJson(original.toJson());

      expect(restored.semester, original.semester);
      expect(restored.sessions, original.sessions);
    });
  });
}
