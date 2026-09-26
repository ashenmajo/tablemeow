import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/data/jwxt/jwxt_course_parser.dart';
import 'package:tablemeow/data/timetable_text_parser.dart';
import 'package:tablemeow/models/course_session.dart';

void main() {
  group('正方课表 JSON 解析', () {
    const String body = '''
[
  {"kcmc":"高等数学 A","xqj":"1","jcs":"1-2","zcd":"1-16周","xm":"王建国","cdmc":"教一101"},
  {"kcmc":"大学英语","xqj":"3","jcs":"3-4","zcd":"1-16周(单)","xm":"Linda","cdmc":"外语楼305"},
  {"kcmc":"体育","xqj":"周六","jcs":"第 1-3 节","zcd":"2-14周(双)","xm":"","cdmc":""}
]
''';

    test('解析课程名 / 星期 / 节次 / 周次 / 地点 / 教师', () {
      final List<CourseSession> sessions = const JwxtCourseParser()
          .parseResponse(body);

      expect(sessions, hasLength(3));
      final CourseSession math = sessions.first;
      expect(math.name, '高等数学 A');
      expect(math.weekday, 1);
      expect(math.startPeriod, 1);
      expect(math.endPeriod, 2);
      expect(math.teacher, '王建国');
      expect(math.location, '教一101');
      expect(math.weeks, List<int>.generate(16, (int index) => index + 1));
    });

    test('支持单双周与中文星期写法', () {
      final List<CourseSession> sessions = const JwxtCourseParser()
          .parseResponse(body);

      expect(sessions[1].weeks, <int>[1, 3, 5, 7, 9, 11, 13, 15]);
      expect(sessions[1].weeksLabel, '1,3,5,7,9,11,13,15周(单)');
      expect(sessions[2].weekday, 6);
      expect(sessions[2].startPeriod, 1);
      expect(sessions[2].endPeriod, 3);
      expect(sessions[2].weeks, <int>[2, 4, 6, 8, 10, 12, 14]);
    });

    test('缺少关键字段的记录会被跳过', () {
      const String broken = '''
[
  {"kcmc":"没有节次","xqj":"1","zcd":"1-16周"},
  {"xqj":"2","jcs":"1-2","zcd":"1-16周"},
  {"kcmc":"完整课程","xqj":"2","jcs":"1-2","zcd":"1-16周"}
]
''';
      final List<CourseSession> sessions = const JwxtCourseParser()
          .parseResponse(broken);

      expect(sessions, hasLength(1));
      expect(sessions.single.name, '完整课程');
    });

    test('兼容 kbList 包裹的返回结构', () {
      const String wrapped = '''
{"kbList":[{"kcmc":"操作系统","xqj":"3","jcs":"5-6","zcd":"1-18周"}]}
''';
      final List<Object?> items = const JwxtCourseParser().decodeItems(wrapped);

      expect(items, hasLength(1));
    });

    test('jcs 的补零紧凑写法按两位一节拆开', () {
      const String body = '''
[
  {"kcmc":"高等数学","xqj":"1","jcs":"0102","zcd":"1-16周"},
  {"kcmc":"大学物理","xqj":"2","jcs":"0304","zcd":"1-16周"},
  {"kcmc":"体育","xqj":"4","jcs":"1112","zcd":"1-16周"}
]
''';
      final List<CourseSession> sessions = const JwxtCourseParser()
          .parseResponse(body);

      expect(sessions, hasLength(3));
      expect((sessions[0].startPeriod, sessions[0].endPeriod), (1, 2));
      expect((sessions[1].startPeriod, sessions[1].endPeriod), (3, 4));
      expect((sessions[2].startPeriod, sessions[2].endPeriod), (11, 12));
    });

    test('缺少 jcor 时仍能靠 jcs 拿到正确节次', () {
      const String body =
          '[{"kcmc":"线性代数","xqj":"3","jcs":"0506","zcd":"1-18周"}]';
      final List<CourseSession> sessions = const JwxtCourseParser()
          .parseResponse(body);

      expect(sessions.single.startPeriod, 5);
      expect(sessions.single.endPeriod, 6);
    });

    test('jcor 与 jcs 同时存在时优先取可读区间', () {
      const String body =
          '[{"kcmc":"离散数学","xqj":"2","jcs":"0304","jcor":"3-4","zcd":"1-18周"}]';

      expect(const JwxtCourseParser().parseResponse(body).single.periodLabel,
          '3-4 节');
    });

    test('节次超出一天的上限时该记录被丢弃', () {
      // 曾经把 `0102` 误读成第 102 节，这类课会被排到课表可视区之外。
      const String body =
          '[{"kcmc":"误读的课","xqj":"1","jcs":"9999","zcd":"1-18周"}]';

      expect(const JwxtCourseParser().parseResponse(body), isEmpty);
    });

    test('响应带 BOM 也能解析', () {
      const String body =
          '\ufeff[{"kcmc":"操作系统","xqj":"5","jcs":"1-2","zcd":"1-18周"}]';

      expect(const JwxtCourseParser().parseResponse(body), hasLength(1));
    });
  });

  group('节次文本', () {
    test('支持紧凑补零、区间与单节写法', () {
      expect(JwxtCourseParser.parsePeriods('0102'), (1, 2));
      expect(JwxtCourseParser.parsePeriods('1112'), (11, 12));
      expect(JwxtCourseParser.parsePeriods('1-2'), (1, 2));
      expect(JwxtCourseParser.parsePeriods('第 3-4 节'), (3, 4));
      expect(JwxtCourseParser.parsePeriods('3'), (3, 3));
      expect(JwxtCourseParser.parsePeriods('05'), (5, 5));
    });

    test('越界或无法识别的写法返回 null', () {
      expect(JwxtCourseParser.parsePeriods(''), isNull);
      expect(JwxtCourseParser.parsePeriods('第节'), isNull);
      expect(JwxtCourseParser.parsePeriods('0102-0304'), isNull);
      expect(JwxtCourseParser.parsePeriods('9999'), isNull);
    });
  });

  group('周次文本', () {
    test('压缩为可读文本', () {
      expect(CourseSession.formatWeeks(<int>[1, 2, 3, 4, 5]), '1-5周');
      expect(CourseSession.formatWeeks(<int>[1, 3, 5, 7]), '1,3,5,7周(单)');
      expect(CourseSession.formatWeeks(<int>[2, 4, 6]), '2,4,6周(双)');
      expect(CourseSession.formatWeeks(<int>[1, 2, 3, 7, 8]), '1-3,7-8周');
    });
  });

  group('粘贴导入', () {
    test('解析逗号分隔的表格文本', () {
      const String text = '''
课程名,星期,节次,周次,地点,教师
高等数学,周一,1-2,1-16周,教一101,王建国
数据结构,周二,3-4,1-16周,教二208,李慕白
''';
      final TimetableParseOutcome outcome = const TimetableTextParser().parse(
        text,
      );

      expect(outcome.sessions, hasLength(2));
      expect(outcome.warnings, isEmpty);
      expect(outcome.sessions.first.name, '高等数学');
      expect(outcome.sessions.first.location, '教一101');
      expect(outcome.sessions.last.teacher, '李慕白');
    });

    test('字段不足的行会给出提示', () {
      const String text = '高等数学,周一\n数据结构,周二,3-4,1-16周';
      final TimetableParseOutcome outcome = const TimetableTextParser().parse(
        text,
      );

      expect(outcome.sessions, hasLength(1));
      expect(outcome.warnings, hasLength(1));
    });

    test('识别 JSON 文本', () {
      const String text =
          '[{"kcmc":"线性代数","xqj":"2","jcs":"3-4","zcd":"1-18周"}]';
      final TimetableParseOutcome outcome = const TimetableTextParser().parse(
        text,
      );

      expect(outcome.sessions, hasLength(1));
      expect(outcome.sessions.single.weeks, hasLength(18));
    });
  });
}
