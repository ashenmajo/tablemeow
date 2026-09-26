import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/models/period_time.dart';
import 'package:tablemeow/models/semester.dart';
import 'package:tablemeow/utils/timeline.dart';

void main() {
  const double cellHeight = 60;
  const List<PeriodTime> periods = Semester.defaultPeriods;

  /// 2026-03-11 是周三，用它的时刻构造「当天某时某分」。
  DateTime at(int hour, int minute, [int second = 0]) =>
      DateTime(2026, 3, 11, hour, minute, second);

  test('时间线落在正在上的那节课内', () {
    // 第 1 节 08:00-08:45，过半即 0.5 * 60。
    final double? offset = Timeline.offsetOf(
      periods,
      at(8, 22, 30),
      cellHeight: cellHeight,
    );

    expect(offset, isNotNull);
    expect(offset!, closeTo(30, 1));
  });

  test('时间线按节次递增', () {
    final double? first = Timeline.offsetOf(
      periods,
      at(8, 10),
      cellHeight: cellHeight,
    );
    final double? fifth = Timeline.offsetOf(
      periods,
      at(14, 10),
      cellHeight: cellHeight,
    );

    expect(first, isNotNull);
    expect(fifth, isNotNull);
    expect(first!, lessThan(cellHeight));
    expect(fifth!, greaterThanOrEqualTo(4 * cellHeight));
    expect(fifth, lessThan(5 * cellHeight));
  });

  test('课间与课外时间不显示时间线', () {
    // 08:45-08:55 是第 1、2 节之间的课间。
    expect(
      Timeline.offsetOf(periods, at(8, 50), cellHeight: cellHeight),
      isNull,
    );
    // 凌晨没有任何课。
    expect(
      Timeline.offsetOf(periods, at(3, 0), cellHeight: cellHeight),
      isNull,
    );
  });

  test('最后一节课也能定位', () {
    // 第 11 节 20:50-21:35。
    final double? offset = Timeline.offsetOf(
      periods,
      at(21, 0),
      cellHeight: cellHeight,
    );

    expect(offset, isNotNull);
    expect(offset!, greaterThanOrEqualTo(10 * cellHeight));
    expect(offset, lessThan(11 * cellHeight));
  });
}
