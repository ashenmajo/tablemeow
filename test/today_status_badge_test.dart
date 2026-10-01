import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/models/timetable.dart';
import 'package:tablemeow/pages/today_page.dart';

void main() {
  // 8:00 - 9:40 的一节课，下面都拿它做参照。
  PeriodTimeRange range() => PeriodTimeRange(
    start: DateTime(2026, 9, 28, 8),
    end: DateTime(2026, 9, 28, 9, 40),
  );

  String upcomingLabel(DateTime now) => courseStatusLabel(
    status: courseStatusOf(range(), now),
    range: range(),
    now: now,
  );

  String ongoingLabel(DateTime now) => courseStatusLabel(
    status: courseStatusOf(range(), now),
    range: range(),
    now: now,
  );

  group('courseStatusOf', () {
    test('上课前 / 进行中 / 下课后', () {
      expect(
        courseStatusOf(range(), DateTime(2026, 9, 28, 7, 59)),
        CourseStatus.upcoming,
      );
      expect(
        courseStatusOf(range(), DateTime(2026, 9, 28, 8)),
        CourseStatus.ongoing,
        reason: '到点即算进行中',
      );
      expect(
        courseStatusOf(range(), DateTime(2026, 9, 28, 9, 40)),
        CourseStatus.ongoing,
        reason: '下课那一瞬间仍算进行中',
      );
      expect(
        courseStatusOf(range(), DateTime(2026, 9, 28, 9, 40, 1)),
        CourseStatus.finished,
      );
    });

    test('没有节次时间时为 unknown', () {
      expect(
        courseStatusOf(null, DateTime(2026, 9, 28, 7)),
        CourseStatus.unknown,
      );
    });
  });

  group('courseStatusLabel 向上取整，不少报一分钟', () {
    test('剩余时间是整分钟时显示同一个数', () {
      expect(upcomingLabel(DateTime(2026, 9, 28, 7, 30)), '30 分钟后');
    });

    test('多出几秒也要算成一分钟（原实现会少一分钟）', () {
      // 7:30:20 -> 差 29 分 40 秒。旧的 Duration.inMinutes 会截断成 29。
      expect(upcomingLabel(DateTime(2026, 9, 28, 7, 30, 20)), '30 分钟后');
      // 7:29:01 -> 差 30 分 59 秒，同样是 31 而不是 30。
      expect(upcomingLabel(DateTime(2026, 9, 28, 7, 29, 1)), '31 分钟后');
    });

    test('不足一分钟也不会显示 0 分钟', () {
      expect(upcomingLabel(DateTime(2026, 9, 28, 7, 59, 30)), '1 分钟后');
      expect(upcomingLabel(DateTime(2026, 9, 28, 7, 59, 59, 500)), '1 分钟后');
    });

    test('超过一小时显示「几小时几分钟」，不糊成整小时', () {
      // 60 分钟整与 59 分 30 秒（取整成 60）都算一小时。
      expect(upcomingLabel(DateTime(2026, 9, 28, 7)), '1 小时后');
      expect(upcomingLabel(DateTime(2026, 9, 28, 7, 0, 30)), '1 小时后');
      // 61 分钟如实写成 1 小时 1 分钟，既不缩成「1 小时后」也不多报成 2 小时。
      expect(upcomingLabel(DateTime(2026, 9, 28, 6, 59)), '1 小时 1 分钟后');
      expect(upcomingLabel(DateTime(2026, 9, 28, 6, 59, 30)), '1 小时 1 分钟后');
      // 119 分钟 = 1 小时 59 分钟，正好贴着下一小时的边界。
      expect(upcomingLabel(DateTime(2026, 9, 28, 6, 1)), '1 小时 59 分钟后');
      expect(upcomingLabel(DateTime(2026, 9, 28, 5, 30)), '2 小时 30 分钟后');
      // 整小时只报小时。
      expect(upcomingLabel(DateTime(2026, 9, 28, 6)), '2 小时后');
      expect(upcomingLabel(DateTime(2026, 9, 28, 4)), '4 小时后');
    });

    test('进行中显示剩余时间，超过一小时同样拆成小时 + 分钟', () {
      expect(ongoingLabel(DateTime(2026, 9, 28, 9, 39, 30)), '进行中 · 还剩 1 分钟');
      expect(ongoingLabel(DateTime(2026, 9, 28, 9, 40)), '进行中 · 还剩 0 分钟');
      expect(ongoingLabel(DateTime(2026, 9, 28, 9, 0)), '进行中 · 还剩 40 分钟');
      expect(ongoingLabel(DateTime(2026, 9, 28, 8, 40)), '进行中 · 还剩 1 小时');
      expect(ongoingLabel(DateTime(2026, 9, 28, 8)), '进行中 · 还剩 1 小时 40 分钟');
      expect(
        ongoingLabel(DateTime(2026, 9, 28, 8, 0, 20)),
        '进行中 · 还剩 1 小时 40 分钟',
        reason: '余下的 40 秒仍然向上取整，不能少报',
      );
    });

    test('已结束 / 待上课', () {
      expect(upcomingLabel(DateTime(2026, 9, 28, 10)), '已结束');
      expect(
        courseStatusLabel(
          status: CourseStatus.unknown,
          range: null,
          now: DateTime(2026, 9, 28, 7),
        ),
        '待上课',
      );
    });
  });
}
