import '../models/course_session.dart';
import 'jwxt/jwxt_course_parser.dart';

/// 粘贴导入的解析结果。
class TimetableParseOutcome {
  const TimetableParseOutcome({
    required this.sessions,
    this.warnings = const <String>[],
  });

  final List<CourseSession> sessions;

  /// 无法识别的行等提示信息。
  final List<String> warnings;

  bool get isEmpty => sessions.isEmpty;
}

/// 解析手工粘贴的课表文本。
///
/// 支持两种格式：
/// 1. 正方教务系统课表接口返回的 JSON；
/// 2. 每行一条记录的表格文本，字段顺序为
///    `课程名, 星期, 节次, 周次, 地点, 教师`（后两项可省略）。
class TimetableTextParser {
  const TimetableTextParser({this.totalWeeks = 20});

  final int totalWeeks;

  TimetableParseOutcome parse(String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const TimetableParseOutcome(
        sessions: <CourseSession>[],
        warnings: <String>['内容为空'],
      );
    }
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      return _parseJson(trimmed);
    }
    return _parseDelimited(trimmed);
  }

  TimetableParseOutcome _parseJson(String text) {
    final JwxtCourseParser parser = JwxtCourseParser(totalWeeks: totalWeeks);
    final List<Object?> items = parser.decodeItems(text);
    if (items.isEmpty) {
      return const TimetableParseOutcome(
        sessions: <CourseSession>[],
        warnings: <String>['没有从 JSON 中解析到课程记录'],
      );
    }
    final List<CourseSession> sessions = parser.parseItems(items);
    return TimetableParseOutcome(
      sessions: sessions,
      warnings: sessions.isEmpty
          ? const <String>['课程记录缺少必要字段']
          : const <String>[],
    );
  }

  TimetableParseOutcome _parseDelimited(String text) {
    final List<CourseSession> sessions = <CourseSession>[];
    final List<String> warnings = <String>[];
    final List<String> lines = text.split(RegExp(r'\r?\n'));

    for (int index = 0; index < lines.length; index++) {
      final String line = lines[index].trim();
      if (line.isEmpty) {
        continue;
      }
      final List<String> cells = line
          .split(RegExp(r'[\t,;，；]'))
          .map((String cell) => cell.trim())
          .toList();
      if (index == 0 &&
          (cells.first.contains('课程') || cells.first.contains('名称'))) {
        continue;
      }
      if (cells.length < 4) {
        warnings.add('第 ${index + 1} 行字段不足，已跳过');
        continue;
      }

      final String name = cells[0];
      final int? weekday = JwxtCourseParser.parseWeekday(cells[1]);
      final (int, int)? periods = JwxtCourseParser.parsePeriods(cells[2]);
      if (name.isEmpty || weekday == null || periods == null) {
        warnings.add('第 ${index + 1} 行无法识别，已跳过');
        continue;
      }
      final List<int> weeks = JwxtCourseParser.parseWeeks(
        cells[3],
        totalWeeks: totalWeeks,
      );

      sessions.add(
        CourseSession(
          name: name,
          weekday: weekday,
          startPeriod: periods.$1,
          endPeriod: periods.$2,
          weeks: weeks.isEmpty
              ? <int>[for (int week = 1; week <= totalWeeks; week++) week]
              : weeks,
          location: cells.length > 4 ? cells[4] : '',
          teacher: cells.length > 5 ? cells[5] : '',
        ),
      );
    }
    return TimetableParseOutcome(sessions: sessions, warnings: warnings);
  }
}
