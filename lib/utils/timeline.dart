import '../models/period_time.dart';

/// 课外时间之外，课表时间线的最小/最大纵向位置。
///
/// 把「当前时间在第几节课的什么位置」抽成纯函数，便于单测。
class Timeline {
  const Timeline._();

  /// [now] 在 [periods] 排布中的纵向偏移（单位与 [cellHeight] 一致）。
  ///
  /// 时间落在某节课的起止之间时返回该位置的偏移；
  /// 落在课间或课程表以外的时间时返回 null（此时不画时间线）。
  static double? offsetOf(
    List<PeriodTime> periods,
    DateTime now, {
    required double cellHeight,
  }) {
    for (int index = 0; index < periods.length; index++) {
      final PeriodTime period = periods[index];
      final DateTime start = period.startAt(now);
      final DateTime end = period.endAt(now);
      if (now.isBefore(start) || now.isAfter(end)) {
        continue;
      }
      final int totalSeconds = end.difference(start).inSeconds;
      final double progress = totalSeconds <= 0
          ? 0
          : now.difference(start).inSeconds / totalSeconds;
      return index * cellHeight + progress.clamp(0, 1) * cellHeight;
    }
    return null;
  }
}
