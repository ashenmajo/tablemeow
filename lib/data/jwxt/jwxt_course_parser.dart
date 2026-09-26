import 'dart:convert';

import '../../models/course_session.dart';

/// 正方教务系统课表数据的解析器。
///
/// 兼容 `xskbcx_cxXsKb.html` 返回的 JSON 数组，字段名同时兼容
/// `kcmc`/`xqj`/`jcs`/`zcd` 与常见的英文别名。
class JwxtCourseParser {
  const JwxtCourseParser({this.totalWeeks = 20});

  /// 学期总周数，用于裁剪解析出的周次。
  final int totalWeeks;

  /// 匹配 `1-16周`、`1,3,5周(单)`、`2-14周（双周）` 这类周次写法。
  static final RegExp _weeksToken = RegExp(
    r'\d+(?:\s*[-~]\s*\d+)?(?:\s*[,，、]\s*\d+(?:\s*[-~]\s*\d+)?)*\s*周'
    r'(?:\s*[（(]\s*[单双]\s*周?\s*[）)])?',
  );

  /// 匹配写进单元格的节次说明，例如 `[01-02]节`、`第1-2节`、`3节`。
  static final RegExp _periodToken = RegExp(
    r'[\[【(（]?\s*第?\s*\d{1,2}\s*(?:[-~—,，、]\s*\d{1,2})?\s*[\]】)）]?\s*节',
  );

  /// 页面里带 `title` 的字段在 JS 侧拼成 `标题\u0001内容`。
  static const String _partSeparator = '\u0001';

  /// 解析接口返回的 JSON 文本，返回所有上课安排。
  ///
  /// 无法识别或缺少关键字段的记录会被跳过。
  List<CourseSession> parseResponse(String body) {
    final List<Object?> items = decodeItems(body);
    return parseItems(items);
  }

  /// 从 JSON 文本中取出课程条目列表，兼容数组与 `kbList` 包裹的格式。
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

  /// 批量解析课程条目。
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

  /// 解析单条课程记录，字段不足时返回 null。
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
    // 正方接口同时给出 `jcs`（补零紧凑写法，如 `0102`）与 `jcor`
    // （可读区间，如 `1-2`）。逐个字段尝试，取第一个能解析出结果的，
    // 避免某个字段缺失或格式异常时整条记录被丢掉。
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

  /// 解析从课表页面表格里抓到的单元格。
  ///
  /// 每个条目形如 `{weekday, period, span, text}`，
  /// 其中 [span] 是单元格跨的行数（即连堂节数）。
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

  /// 解析单个课表单元格。
  ///
  /// 单元格文本通常是「课程名 / 教师 / 地点 / 周次」的若干行。
  /// 不同厂商的写法差别很大：
  ///
  /// - 正方：`高等数学 / 王建国 / 教一101 / 1-16周`，节次由行号给出；
  /// - 强智：`电磁场与电磁波 / 侯周国 / 副教授 / 2-11(周) / [01-02]节 / 致远-501`，
  ///   节次写在单元格里，一行代表一个大节。
  ///
  /// 因此先把周次与节次说明从文本里摘出来，再用剩下的行区分教师与教室。
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
    // 课表下面的「备注」行放的是没排时间的课，不该出现在课表格子里。
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

    // 单元格里写明节次时以它为准，比「行号 + rowspan」更贴近真实上课节次。
    final RegExpMatch? periodMatch = _periodToken.firstMatch(withoutWeeks);
    // 真正的排课一定带着周次或节次信息。两样都没有的格子多半是
    // 「网络课程」「学习通网课」这类没排时间的占位，导进来只会污染课表。
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
    // 有些页面把各字段挤在同一行，已经没有换行可用，退而用空格再拆一次。
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

    // 页面把字段标了 title 时（强智的 `<font title="老师">` 等）优先用结构化字段，
    // 因为这些元素之间可能没有任何分隔符，靠文本猜是猜不出来的。
    final List<(String, String)> parts = _labeledParts(item['parts']);
    String? labeledTeacher;
    String? labeledLocation;
    for (final (String, String) part in parts) {
      final String key = part.$1;
      final String value = part.$2;
      // 字段明显长于一格内容时说明取到的是整格文字，忽略。
      if (value.length > 40) {
        continue;
      }
      if (key.contains('老师') ||
          key.contains('教师') ||
          key.contains('授课')) {
        // 「副教授」「高等学校教师」是职称，不是姓名。
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

    // 课程名有两个来源：单元格第一行，和带 title 的结构化字段（JS 侧去掉
    // 教师/教室等元素后剩下的文本）。结构化字段在整格粘成一行时更准，
    // 单元格第一行在结构化字段吃掉了课程名时更准；两个都清一遍，取更短的
    // 那个（长出来的部分基本都是教师、职称、学时说明这类附带信息）。
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

  /// 课程名里附带的排课说明要去掉。
  ///
  /// 强智的格子里会出现「课程名 / 一长串短横线 / 课程名(理论:32,实践:16) /
  /// ……」这种重复结构，这里逐层剥掉：先截断到第一条分隔线之前，
  /// 再去掉 `(理论:…)` 这类学时说明，最后把重复出现的前缀合并成一个。
  ///
  /// 导入时会用，读取本地已有的课表时也会再洗一遍，保证旧数据也能修正。
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

  /// `电磁场与电磁波 电磁场与电磁波` → `电磁场与电磁波`。
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
    // 「课程名 课程名(理论…)」这种最常见的重复：后一段是前一段的延伸。
    final String first = parts.first;
    if (parts.length == 2 &&
        (parts[1] == first || parts[1].startsWith(first))) {
      return first;
    }
    return value;
  }

  /// 教师字段里常常连着职称（`谢玮高等学校教师`、`刘湛讲师（高校）`），
  /// 把职称和后面的括注摘掉，只留姓名。
  static String _stripTeacherTitle(String value) {
    String text = cleanText(value);
    if (text.isEmpty) {
      return value;
    }
    // 先去掉「（高校）」「（外聘）」这类跟在职称后面的括注。
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

  /// 解析 JS 传来的结构化字段，每项形如 `标题\u0001内容`。
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

  /// 把 `2-11(周)`、`1-16(双)` 这类写法归一化成 `2-11周`、`1-16(双周)`。
  ///
  /// 强智把「周」写在括号里，直接匹配普通的 `1-16周` 会漏掉。
  static String _normalizeWeekMarkers(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'[（(]\s*([单双])\s*周?\s*[）)]'),
          (Match match) => '(${match.group(1)}周)',
        )
        .replaceAll(RegExp(r'[（(]\s*周\s*[）)]'), '周');
  }

  /// 判断一行是不是上课地点。
  ///
  /// 教室一般带数字（`教一101`、`致远-501`），也可能只有中文楼名（`公共机房四`）。
  static bool _looksLikeLocation(String value) =>
      RegExp(r'\d|[楼室馆场]|机房|教室|校区|操场|体育馆').hasMatch(value);

  /// 判断一行是不是职称而不是教师姓名，例如 `副教授`、`高等学校教师`。
  ///
  /// 只有整行都是职称时才成立，`张三 副教授` 这种拼接串仍然当作姓名。
  static bool _looksLikeTeacherTitle(String value) => RegExp(
    r'^(高等学校|高等|高级|副|助理|外聘|兼职|专职)?'
    r'(教授|讲师|助教|教师|工程师|实验师|研究员|教员)$',
  ).hasMatch(cleanText(value));

  /// 清理课程名里因移除周次而残留的空括号与首尾分隔符。
  ///
  /// 例如 `大学英语(1-16周(单))` 去掉周次后会剩下 `大学英语( )`。
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

  /// 解析星期几，支持 `1`、`周一`、`星期一` 等写法。
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

  /// 一天最多有多少节，超过说明字段格式没有被正确识别。
  ///
  /// 用来挡住「把 `0102` 当成第 102 节」这类误读：这种课会被排到课表
  /// 可视区域之外，导入看起来成功、界面上却什么都看不到。
  static const int maxPeriodsPerDay = 30;

  /// 解析节次，支持 `1-2`、`第 3-4 节`、`0102` 等写法。
  ///
  /// 正方接口的 `jcs` 字段是补零的紧凑写法：`0102` 表示第 1-2 节、
  /// `0304` 表示第 3-4 节，这里按两位一组拆开；解析不出或超出
  /// [maxPeriodsPerDay] 时返回 null。
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

  /// 解析 `0102`、`0304`、`1112` 这类补零的紧凑节次写法。
  ///
  /// 只有 4 位以上的偶数长度才可能是「两位一节」的拼接；
  /// `3`、`12` 这类短写法仍然按单个节次处理。
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

  /// 解析带分隔符的节次写法，支持 `1-2`、`第 3-4 节`、`1,2`。
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
    // `1-2`、`1,2` 取前后两段；`0102` 这类紧凑写法已在上面处理。
    final int start = numbers.first;
    final int end = numbers.last;
    return start < 1 || end < start ? null : (start, end);
  }

  /// 解析周次，支持 `1-16周`、`1-16周(单)`、`1,3,5-9周` 等写法。
  ///
  /// 解析结果会裁剪到 `1..totalWeeks`；文本无法识别时返回空列表。
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

/// 去掉 HTML 标签与常见转义，得到纯文本。
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
