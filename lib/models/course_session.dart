import 'package:flutter/foundation.dart';

/// 一次上课安排：某门课在星期几的第几节到第几节、哪些周上课。

@immutable
class CourseSession {
  const CourseSession({
    required this.name,
    required this.weekday,
    required this.startPeriod,
    required this.endPeriod,
    required this.weeks,
    this.teacher = '',
    this.location = '',
  });

  final String name;

  final int weekday;

  final int startPeriod;

  final int endPeriod;

  final List<int> weeks;

  final String teacher;

  final String location;

  int get periodCount => endPeriod - startPeriod + 1;

  bool occursInWeek(int week) => weeks.contains(week);

  String get periodLabel =>
      startPeriod == endPeriod ? '$startPeriod 节' : '$startPeriod-$endPeriod 节';

  String get weeksLabel => formatWeeks(weeks);

  CourseSession copyWith({
    String? name,
    int? weekday,
    int? startPeriod,
    int? endPeriod,
    List<int>? weeks,
    String? teacher,
    String? location,
  }) {
    return CourseSession(
      name: name ?? this.name,
      weekday: weekday ?? this.weekday,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      weeks: weeks ?? this.weeks,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'weekday': weekday,
    'startPeriod': startPeriod,
    'endPeriod': endPeriod,
    'weeks': weeks,
    'teacher': teacher,
    'location': location,
  };

  factory CourseSession.fromJson(Map<String, dynamic> json) {
    return CourseSession(
      name: (json['name'] as String? ?? '').trim(),
      weekday: (json['weekday'] as num? ?? 1).toInt(),
      startPeriod: (json['startPeriod'] as num? ?? 1).toInt(),
      endPeriod: (json['endPeriod'] as num? ?? 1).toInt(),
      weeks: <int>[
        for (final Object? week
            in (json['weeks'] as List<Object?>? ?? const <Object?>[]))
          if (week is num) week.toInt(),
      ],
      teacher: json['teacher'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }

  static String formatWeeks(List<int> weeks) {
    final List<int> sorted = weeks.toSet().toList()..sort();
    if (sorted.isEmpty) {
      return '未指定';
    }
    final List<String> segments = <String>[];
    int start = sorted.first;
    int previous = sorted.first;
    for (final int week in sorted.skip(1)) {
      if (week == previous + 1) {
        previous = week;
        continue;
      }
      segments.add(start == previous ? '$start' : '$start-$previous');
      start = week;
      previous = week;
    }
    segments.add(start == previous ? '$start' : '$start-$previous');

    final bool allOdd = sorted.every((int week) => week.isOdd);
    final bool allEven = sorted.every((int week) => week.isEven);
    final String suffix = allOdd ? '(单)' : (allEven ? '(双)' : '');
    return "${segments.join(",")}周$suffix";
  }

  @override
  bool operator ==(Object other) {
    return other is CourseSession &&
        other.name == name &&
        other.weekday == weekday &&
        other.startPeriod == startPeriod &&
        other.endPeriod == endPeriod &&
        other.teacher == teacher &&
        other.location == location &&
        listEquals(other.weeks, weeks);
  }

  @override
  int get hashCode => Object.hash(
    name,
    weekday,
    startPeriod,
    endPeriod,
    teacher,
    location,
    Object.hashAll(weeks),
  );

  @override
  String toString() =>
      'CourseSession($name, 周$weekday $periodLabel, $weeksLabel)';
}
