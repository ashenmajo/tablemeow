import '../models/period_time.dart';

class Timeline {
  const Timeline._();
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
