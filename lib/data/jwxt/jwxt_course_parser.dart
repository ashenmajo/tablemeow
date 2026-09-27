import 'dart:convert';

import '../../models/course_session.dart';


class JwxtCourseParser {
  const JwxtCourseParser({this.totalWeeks = 20});

  final int totalWeeks;

  static final RegExp _weeksToken = RegExp(
    r'\d+(?:\s*[-~]\s*\d+)?(?:\s*[,，、]\s*\d+(?:\s*[-~]\s*\d+)?)*\s*周'
    r'(?:\s*[（(]\s*[单双]\s*周?\s*[）)])?',
  );

  static final RegExp _periodToken = RegExp(
    r'[\[【(（]?\s*第?\s*\d{1,2}\s*(?:[-~—,，、]\s*\d{1,2})?\s*[\]】)）]?\s*节',
  );

  static const String _partSeparator = '\u0001';

  List<CourseSession> parseResponse(String body) {
    final List<Object?> items = decodeItems(body);
    return parseItems(items);
  }

  List<Object?> decodeItems(String body) {
    final Object? decoded = _tryDecode(body);
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map) {
      for (final String key in const <String>[
        'kbList',
        'kblist',
        'rows',
        'data',
        'items',
      ]) {
        final Object? value = decoded[key];
        if (value is List) {
          return value;
        }
      }
    }
    return const <Object?>[];
  }

  List<CourseSession> parseItems(List<Object?> items) {
    final List<CourseSession> sessions = <CourseSession>[];
    for (final Object? item in items) {
      if (item is! Map) {
        continue;
      }
      final CourseSession? session = parseItem(item.cast<String, dynamic>());
      if (session != null) {
        sessions.add(session);
      }
    }
    return sessions;
  }

  CourseSession? parseItem(Map<String, dynamic> item) {
    final String name = _text(item, const <String>[
      'kcmc',
      'courseName',
      'name',
    ]);
    if (name.isEmpty) {
      return null;
    }
    final int? weekday = parseWeekday(
      _text(item, const <String>['xqj', 'weekday', 'xingqi']),
    );
    if (weekday == null) {
      return null;
    }

    (int, int)? periods;
    for (final String key in const <String>[
      'jcor',
      'jcs',
      'jcs2',
      'periods',
    ]) {
      periods = parsePeriods(_text(item, <String>[key]));
      if (periods != null) {
        break;
      }
    }
    if (periods == null) {
      return null;
    }
    final List<int> weeks = parseWeeks(
      _text(item, const <String>['zcd', 'zcmc', 'weeks']),
      totalWeeks: totalWeeks,
    );

    return CourseSession(
      name: name,
      weekday: weekday,
      startPeriod: periods.$1,
      endPeriod: periods.$2,
      weeks: weeks.isEmpty ? _allWeeks() : weeks,
      teacher: _text(item, const <String>['xm', 'jsxm', 'teacher']),
      location: _text(item, const <String>[
        'cdmc',
        'jxdd',
        'classroom',
        'location',
      ]),
    );
  }

  List<int> _allWeeks() => <int>[
    for (int week = 1; week <= totalWeeks; week++) week,
  ];

  List<CourseSession> parseScrapedCourses(List<Object?> items) {
    final List<CourseSession> sessions = <CourseSession>[];
    for (final Object? item in items) {
      if (item is! Map) {
        continue;
      }
      final CourseSession? session = parseScrapedItem(
        item.cast<String, dynamic>(),
      );
      if (session != null) {
        sessions.add(session);
      }
    }
    return sessions;
  }

  CourseSession? parseScrapedItem(Map<String, dynamic> item) {
    final int? weekday = (item['weekday'] as num?)?.toInt();
    final int? period = (item['period'] as num?)?.toInt();
    if (weekday == null || weekday < 1 || weekday > 7) {
      return null;
    }
    if (period == null || period < 1) {
      return null;
    }
    final int span = ((item['span'] as num?)?.toInt() ?? 1).clamp(1, 20);
    final String raw = item['text']?.toString() ?? '';
    // 课表下面的备注行放的是没排时间的课，不该出现在课表格子里。
    if (RegExp(r'^\s*(备注|说明|注)\s*[:：]').hasMatch(raw)) {
      return null;
    }

    final String normalized = _normalizeWeekMarkers(raw);
    final RegExpMatch? weeksMatch = _weeksToken.firstMatch(normalized);
    final List<int> weeks = weeksMatch == null
        ? const <int>[]
        : parseWeeks(weeksMatch.group(0)!, totalWeeks: totalWeeks);
    final String withoutWeeks = weeksMatch == null
        ? normalized
        : normalized.replaceRange(weeksMatch.start, weeksMatch.end, ' ');

    final RegExpMatch? periodMatch = _periodToken.firstMatch(withoutWeeks);

    if (weeksMatch == null && periodMatch == null) {
      return null;
    }
    final (int, int)? scrapedPeriods = periodMatch == null
        ? null
        : parsePeriods(
            periodMatch.group(0)!.replaceAll(
              RegExp(r'[\[\]【】()（）节]'),
              '',
            ),
          );
    final String body = periodMatch == null
        ? withoutWeeks
        : withoutWeeks.replaceRange(periodMatch.start, periodMatch.end, ' ');

    List<String> segments = body
        .split(RegExp(r'[\r\n]+|<br\s*/?>', caseSensitive: false))
        .map(cleanText)
        .where((String segment) => segment.isNotEmpty)
        .toList();
    if (segments.length == 1 &&
        RegExp(r'\s').allMatches(segments.first).length >= 2) {
      segments = segments.first
          .split(RegExp(r'\s+'))
          .map(cleanText)
          .where((String segment) => segment.isNotEmpty)
          .toList();
    }
    if (segments.isEmpty) {
      return null;
    }

    final List<(String, String)> parts = _labeledParts(item['parts']);
    String? labeledTeacher;
    String? labeledLocation;
    for (final (String, String) part in parts) {
      final String key = part.$1;
      final String value = part.$2;
      if (value.length > 40) {
        continue;
      }
      if (key.contains('老师') ||
          key.contains('教师') ||
          key.contains('授课')) {
        if (!_looksLikeTeacherTitle(value)) {
          labeledTeacher ??= value;
        }
      } else if (key.contains('教室') ||
          key.contains('地点') ||
          key.contains('场地')) {
        labeledLocation ??= value;
      }
    }

    String teacher = '';
    String location = '';
    String teacherTitle = '';
    for (final String segment in segments.skip(1)) {
      if (_looksLikeLocation(segment)) {
        location = location.isEmpty ? segment : location;
      } else if (_looksLikeTeacherTitle(segment)) {
        teacherTitle = teacherTitle.isEmpty ? segment : teacherTitle;
      } else if (teacher.isEmpty) {
        teacher = segment;
      }
    }
    if (teacher.isEmpty) {
      teacher = teacherTitle;
    }

    final String fromSegments = _cleanCourseName(segments.first);
    final String fromLabeled = _cleanCourseName(
      cleanText(item['name']?.toString() ?? ''),
    );
    final String name;
    if (fromLabeled.isEmpty) {
      name = fromSegments;
    } else if (fromSegments.isEmpty) {
      name = fromLabeled;
    } else {
      name = fromLabeled.length <= fromSegments.length
          ? fromLabeled
          : fromSegments;
    }
    final int startPeriod = scrapedPeriods?.$1 ?? period;
    final int endPeriod = scrapedPeriods?.$2 ?? period + span - 1;
    return CourseSession(
      name: name,
      weekday: weekday,
      startPeriod: startPeriod,
      endPeriod: endPeriod < startPeriod ? startPeriod : endPeriod,
      weeks: weeks.isEmpty ? _allWeeks() : weeks,
      teacher: _stripTeacherTitle(labeledTeacher ?? teacher),
      location: labeledLocation ?? location,
    );
  }

  static String cleanCourseName(String value) => _cleanCourseName(value);

  static String _cleanCourseName(String value) {
    String name = _normalizeName(
      _normalizeWeekMarkers(value)
          .replaceAll(_weeksToken, ' ')
          .replaceAll(_periodToken, ' '),
    );
    final int separator = name.indexOf(RegExp(r'[-—–_]{3,}'));
    if (separator > 0) {
      name = name.substring(0, separator);
    }
    final int hours = name.indexOf(RegExp(r'[（(]\s*(理论|实践|学时)'));
    if (hours > 0) {
      name = name.substring(0, hours);
    }
    return _normalizeName(_collapseRepeats(cleanText(name)));
  }
  static String _collapseRepeats(String value) {
    final List<String> parts = value
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.length < 2) {
      return value;
    }
    if (parts.length > 2 && parts.length.isEven) {
      final int half = parts.length ~/ 2;
      if (parts.sublist(0, half).join(' ') == parts.sublist(half).join(' ')) {
        return parts.sublist(0, half).join(' ');
      }
    }
    final String first = parts.first;
    if (parts.length == 2 &&
        (parts[1] == first || parts[1].startsWith(first))) {
      return first;
    }
    return value;
  }

  static String _stripTeacherTitle(String value) {
    String text = cleanText(value);
    if (text.isEmpty) {
      return value;
    }

    text = text.replaceAll(
      RegExp(r'[（(]\s*(高校|企业|外聘|兼职|专职|返聘)\s*[）)]\s*$'),
      '',
    );
    final RegExpMatch? match = RegExp(
      r'^(.*?)\s*(?:高等学校|高等|高级|副|助理|外聘|兼职|专职)?'
      r'(?:教授|讲师|助教|教师|工程师|实验师|研究员|教员)$',
    ).firstMatch(text);
    if (match == null) {
      return text.isEmpty ? value : text;
    }
    final String name = match.group(1)!.trim();
    return name.isEmpty ? value : name;
  }

  static List<(String, String)> _labeledParts(Object? raw) {
    if (raw is! List) {
      return const <(String, String)>[];
    }
    final List<(String, String)> parts = <(String, String)>[];
    for (final Object? item in raw) {
      final String text = item?.toString() ?? '';
      final int separator = text.indexOf(_partSeparator);
      if (separator <= 0) {
        continue;
      }
      final String title = cleanText(text.substring(0, separator));
      final String value = cleanText(text.substring(separator + 1));
      if (title.isNotEmpty && value.isNotEmpty) {
        parts.add((title, value));
      }
    }
    return parts;
  }


  static String _normalizeWeekMarkers(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'[（(]\s*([单双])\s*周?\s*[）)]'),
          (Match match) => '(${match.group(1)}周)',
        )
        .replaceAll(RegExp(r'[（(]\s*周\s*[）)]'), '周');
  }

  static bool _looksLikeLocation(String value) =>
      RegExp(r'\d|[楼室馆场]|机房|教室|校区|操场|体育馆').hasMatch(value);


  static bool _looksLikeTeacherTitle(String value) => RegExp(
    r'^(高等学校|高等|高级|副|助理|外聘|兼职|专职)?'
    r'(教授|讲师|助教|教师|工程师|实验师|研究员|教员)$',
  ).hasMatch(cleanText(value));


  static String _normalizeName(String value) {
    String name = cleanText(value.replaceAll(RegExp(r'[（(]\s*[）)]'), ' '));
    const String trailing = '（(),，、-—:：';
    while (name.isNotEmpty && trailing.contains(name[name.length - 1])) {
      name = name.substring(0, name.length - 1).trimRight();
    }
    const String leading = '（(),，、';
    while (name.isNotEmpty && leading.contains(name[0])) {
      name = name.substring(1).trimLeft();
    }
    return name;
  }

  static int? parseWeekday(String text) {
    final String value = text.trim();
    if (value.isEmpty) {
      return null;
    }
    final int? direct = int.tryParse(value);
    if (direct != null) {
      return direct >= 1 && direct <= 7 ? direct : null;
    }
    const Map<String, int> labels = <String, int>{
      '一': 1,
      '二': 2,
      '三': 3,
      '四': 4,
      '五': 5,
      '六': 6,
      '日': 7,
      '天': 7,
    };
    for (final MapEntry<String, int> entry in labels.entries) {
      if (value.contains(entry.key)) {
        return entry.value;
      }
    }
    final RegExpMatch? match = RegExp(r'[1-7]').firstMatch(value);
    return match == null ? null : int.parse(match.group(0)!);
  }

  static const int maxPeriodsPerDay = 30;


  /// maxPeriodsPerDay时返回 null。
  static (int, int)? parsePeriods(String text) {
    final String value = text.trim();
    if (value.isEmpty) {
      return null;
    }
    final (int, int)? periods =
        _parseCompactPeriods(value) ?? _parsePeriodsText(value);
    if (periods == null) {
      return null;
    }
    final int start = periods.$1;
    final int end = periods.$2;
    if (start < 1 || end < start || end > maxPeriodsPerDay) {
      return null;
    }
    return (start, end);
  }

  static (int, int)? _parseCompactPeriods(String value) {
    if (value.length < 4 || value.length.isOdd) {
      return null;
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return null;
    }
    final int start = int.parse(value.substring(0, 2));
    final int end = int.parse(value.substring(value.length - 2));
    if (start < 1 || end < start) {
      return null;
    }
    return (start, end);
  }

  static (int, int)? _parsePeriodsText(String value) {
    final List<int> numbers = <int>[
      for (final RegExpMatch match in RegExp(r'\d+').allMatches(value))
        int.parse(match.group(0)!),
    ];
    if (numbers.isEmpty) {
      return null;
    }
    if (numbers.length == 1) {
      final int period = numbers.first;
      return period < 1 ? null : (period, period);
    }
    final int start = numbers.first;
    final int end = numbers.last;
    return start < 1 || end < start ? null : (start, end);
  }

  static List<int> parseWeeks(String text, {int totalWeeks = 20}) {
    final String normalized = text
        .replaceAll('（', '(')
        .replaceAll('）', ')')
        .replaceAll('周', '')
        .trim();
    if (normalized.isEmpty) {
      return const <int>[];
    }
    final bool singleWeekOnly = normalized.contains('单');
    final bool doubleWeekOnly = normalized.contains('双');

    final StringBuffer buffer = StringBuffer();
    for (final int rune in normalized.runes) {
      final String char = String.fromCharCode(rune);
      if (RegExp(r'\d').hasMatch(char)) {
        buffer.write(char);
      } else if (char == '-' || char == '~' || char == '—') {
        buffer.write('-');
      } else if (char == ',' || char == '，') {
        buffer.write(',');
      }
    }

    final Set<int> weeks = <int>{};
    for (final String segment in buffer.toString().split(',')) {
      if (segment.isEmpty) {
        continue;
      }
      final List<String> parts = segment.split('-');
      final int? start = int.tryParse(parts.first);
      if (start == null) {
        continue;
      }
      final int end = parts.length > 1
          ? int.tryParse(parts[1]) ?? start
          : start;
      for (int week = start; week <= end; week++) {
        if (week >= 1 && week <= totalWeeks) {
          weeks.add(week);
        }
      }
    }
    if (singleWeekOnly) {
      weeks.removeWhere((int week) => week.isEven);
    }
    if (doubleWeekOnly) {
      weeks.removeWhere((int week) => week.isOdd);
    }
    return weeks.toList()..sort();
  }

  static Object? _tryDecode(String body) {
    try {
      // 部分学校站点会在 JSON 前带 BOM 或空白，先清掉再解析。
      return jsonDecode(body.replaceAll('\ufeff', '').trim());
    } catch (_) {
      return null;
    }
  }

  static String _text(Map<String, dynamic> item, List<String> keys) {
    for (final String key in keys) {
      final Object? value = item[key];
      if (value == null) {
        continue;
      }
      final String text = cleanText(value.toString());
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }
}

String cleanText(String value) {
  return value
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('\u00a0', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
