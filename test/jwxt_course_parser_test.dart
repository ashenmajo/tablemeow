import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/data/jwxt/jwxt_course_parser.dart';
import 'package:tablemeow/models/course_session.dart';

/// 用真实教务系统（强智）导出的课表文本做回归：
/// 同一格子里按周次段拆成多条的课程，导入后不得丢失后面的周次。
void main() {
  const JwxtCourseParser parser = JwxtCourseParser();

  // 湖南人文科技学院「学生个人课表」周一第三四大节的真实文本：
  // 面向对象被拆成 2-5 / 6-9 / 10-13 三段挤在同一格。
  const String multiSegmentCell = '''
面向对象程序设计及实践B
李朝鹏(副教授)
2-5([周])[03-04节]
专业五机房（一）

面向对象程序设计及实践B
李朝鹏(副教授)
6-9([周])[03-04节]
专业五机房（一）

面向对象程序设计及实践B
李朝鹏(副教授)
10-13([周])[03-04节]
专业五机房（一）
''';

  Map<String, Object?> cell({
    required int weekday,
    required int period,
    required String text,
    int span = 2,
  }) => <String, Object?>{
    'weekday': weekday,
    'period': period,
    'span': span,
    'text': text,
    'name': '',
    'parts': <Object?>[],
  };

  test('同一格子多段周次全部保留并合并成一条', () {
    final List<CourseSession> sessions = parser.parseScrapedCourses(
      <Object?>[cell(weekday: 1, period: 3, text: multiSegmentCell)],
    );

    expect(sessions, hasLength(1));
    expect(sessions.first.name, '面向对象程序设计及实践B');
    expect(sessions.first.weekday, 1);
    expect(sessions.first.startPeriod, 3);
    expect(sessions.first.endPeriod, 4);
    expect(
      sessions.first.weeks,
      <int>[2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
    );
    expect(sessions.first.location, '专业五机房（一）');
    expect(sessions.first.teacher, contains('李朝鹏'));
  });

  test('嵌入式系统三段（8-11/12-13/14-17）合并为 8-17 周', () {
    const String text = '''
嵌入式系统
谢玮(高等学校教师)
8-11([周])[01-02节]
公共机房四

嵌入式系统
谢玮(高等学校教师)
12-13([周])[01-02节]
公共机房四

嵌入式系统
谢玮(高等学校教师)
14-17([周])[01-02节]
公共机房四
''';
    final List<CourseSession> sessions = parser.parseScrapedCourses(
      <Object?>[cell(weekday: 3, period: 1, text: text)],
    );

    expect(sessions, hasLength(1));
    expect(
      sessions.first.weeks,
      <int>[8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    );
    expect(sessions.first.location, '公共机房四');
  });

  test('单段周次的课不受影响（习概 2-17 周）', () {
    const String text = '''
习近平新时代中国特色社会主义思想概论
康珏(助教（高校）),唐芳云(副教授)
2-17([周])[05-06节]
致远-320
''';
    final List<CourseSession> sessions = parser.parseScrapedCourses(
      <Object?>[cell(weekday: 1, period: 5, text: text)],
    );

    expect(sessions, hasLength(1));
    expect(
      sessions.first.weeks,
      <int>[for (int week = 2; week <= 17; week++) week],
    );
    expect(sessions.first.startPeriod, 5);
    expect(sessions.first.endPeriod, 6);
  });

  test('同格子两段节次不同时不合并，各配各的节次', () {
    const String text = '''
课程甲
张三
1-8([周])[03-04节]
教1-301

课程甲
张三
9-16([周])[05-06节]
教1-301
''';
    final List<CourseSession> sessions = parser.parseScrapedCourses(
      <Object?>[cell(weekday: 2, period: 3, text: text)],
    );

    expect(sessions, hasLength(2));
    expect(sessions[0].startPeriod, 3);
    expect(sessions[0].endPeriod, 4);
    expect(sessions[0].weeks, <int>[for (int w = 1; w <= 8; w++) w]);
    expect(sessions[1].startPeriod, 5);
    expect(sessions[1].endPeriod, 6);
    expect(sessions[1].weeks, <int>[for (int w = 9; w <= 16; w++) w]);
  });

  test('中间有断档的两段合并后保留断档（2-5 + 9-13）', () {
    const String text = '''
课程乙
李四
2-5([周])[03-04节]
教2-201

课程乙
李四
9-13([周])[03-04节]
教2-201
''';
    final List<CourseSession> sessions = parser.parseScrapedCourses(
      <Object?>[cell(weekday: 4, period: 3, text: text)],
    );

    expect(sessions, hasLength(1));
    expect(sessions.first.weeks, <int>[2, 3, 4, 5, 9, 10, 11, 12, 13]);
  });

  test('没写周次的格子仍然整学期兜底', () {
    const String text = '''
高等数学
王五
[03-04节]
教1-301
''';
    final List<CourseSession> sessions = parser.parseScrapedCourses(
      <Object?>[cell(weekday: 5, period: 3, text: text)],
    );

    expect(sessions, hasLength(1));
    expect(sessions.first.weeks, <int>[for (int w = 1; w <= 20; w++) w]);
    expect(sessions.first.startPeriod, 3);
    expect(sessions.first.endPeriod, 4);
  });

  test('备注行仍然被丢弃', () {
    const String text = '备注：嵌入式系统课程设计 刘湛 17-18周;';
    final List<CourseSession> sessions = parser.parseScrapedCourses(
      <Object?>[cell(weekday: 3, period: 9, text: text)],
    );

    expect(sessions, isEmpty);
  });

  test('正方 JSON 接口路径不受影响（zcd 单双周）', () {
    final String body = jsonEncode(<String, dynamic>{
      'kbList': <Map<String, dynamic>>[
        <String, dynamic>{
          'kcmc': '大学物理',
          'xqj': '2',
          'jcor': '0102',
          'zcd': '1-16周(单)',
          'xm': '赵六',
          'cdmc': 'A-201',
        },
      ],
    });

    final List<CourseSession> sessions = parser.parseResponse(body);

    expect(sessions, hasLength(1));
    expect(sessions.first.name, '大学物理');
    expect(sessions.first.startPeriod, 1);
    expect(sessions.first.endPeriod, 2);
    expect(
      sessions.first.weeks,
      <int>[1, 3, 5, 7, 9, 11, 13, 15],
    );
  });
}
