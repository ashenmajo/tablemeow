import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/data/jwxt/jwxt_course_parser.dart';
import 'package:tablemeow/data/timetable_storage.dart';
import 'package:tablemeow/models/course_session.dart';
import 'package:tablemeow/state/app_state.dart';

/// 端到端导入管道回归：模拟 WebView 从教务系统抓回的课程条目
/// （按湖南人文科技学院「学期理论课表」真实结构还原），
/// 走 解析 → importSessions 入库 → 重新加载 的完整链路。
void main() {
  test('整表抓取结果解析出 8 条课程，多段周次不丢失', () {
    final List<CourseSession> sessions = const JwxtCourseParser()
        .parseScrapedCourses(_scrapedCourses());

    expect(sessions, hasLength(8));

    final CourseSession faceMonday = sessions.firstWhere(
      (CourseSession s) => s.name.contains('面向对象') && s.weekday == 1,
    );
    expect(faceMonday.startPeriod, 3);
    expect(faceMonday.endPeriod, 4);
    expect(
      faceMonday.weeks,
      <int>[for (int w = 2; w <= 13; w++) w],
      reason: '2-5 + 6-9 + 10-13 三段合并为连续 2-13 周',
    );

    final CourseSession embedWednesday = sessions.firstWhere(
      (CourseSession s) => s.name.contains('嵌入式') && s.weekday == 3,
    );
    expect(
      embedWednesday.weeks,
      <int>[for (int w = 8; w <= 17; w++) w],
      reason: '8-11 + 12-13 + 14-17 三段合并为连续 8-17 周',
    );
  });

  test('解析结果入库并重新加载后数据一致', () async {
    final List<CourseSession> sessions = const JwxtCourseParser()
        .parseScrapedCourses(_scrapedCourses());
    final _FakeStorage storage = _FakeStorage();

    final AppState state = AppState(
      storage: storage,
      clock: () => DateTime(2026, 9, 28, 10, 30),
    );
    await state.load();
    await state.importSessions(sessions);

    expect(state.sessions, hasLength(8));
    expect(storage.data, isNotNull, reason: '导入后必须已持久化');

    // 模拟杀掉应用重新打开：从同一份存储读回。
    final AppState reloaded = AppState(
      storage: storage,
      clock: () => DateTime(2026, 9, 28, 10, 30),
    );
    await reloaded.load();
    expect(reloaded.sessions, hasLength(8));
    expect(reloaded.sessions.firstWhere((CourseSession s) => s.name.contains('信号') && s.weekday == 5).weeks,
        <int>[for (int w = 2; w <= 15; w++) w]);
  });
}

/// 模拟抓取脚本回传的 courses：每格一条，key 与
/// JwxtWebScripts.extractCourses 的输出一致（weekday/period/span/text/name/parts）。
/// 行按大节排列：第1行=01,02节（period 1）、第2行=03,04节（period 2）……
List<Object?> _scrapedCourses() => <Object?>[
      <String, Object?>{
        'weekday': 1,
        'period': 1,
        'span': 2,
        'name': '',
        'parts': <Object?>[],
        'text': '电磁场与电磁波\n侯周国(副教授)\n2-11周[01-02节]\n致远-501',
      },
      <String, Object?>{
        'weekday': 3,
        'period': 1,
        'span': 2,
        'name': '',
        'parts': <Object?>[],
        'text': '嵌入式系统\n谢玮(高等学校教师)\n8-11周[01-02节]\n公共机房四\n\n'
            '嵌入式系统\n谢玮(高等学校教师)\n12-13周[01-02节]\n公共机房四\n\n'
            '嵌入式系统\n谢玮(高等学校教师)\n14-17周[01-02节]\n公共机房四',
      },
      <String, Object?>{
        'weekday': 4,
        'period': 1,
        'span': 2,
        'name': '',
        'parts': <Object?>[],
        'text': '嵌入式系统\n谢玮(高等学校教师)\n8-11周[01-02节]\n公共机房四\n\n'
            '嵌入式系统\n谢玮(高等学校教师)\n12-13周[01-02节]\n公共机房四\n\n'
            '嵌入式系统\n谢玮(高等学校教师)\n14-17周[01-02节]\n公共机房四',
      },
      <String, Object?>{
        'weekday': 1,
        'period': 2,
        'span': 2,
        'name': '',
        'parts': <Object?>[],
        'text': '面向对象程序设计及实践B\n李朝鹏(副教授)\n2-5周[03-04节]\n专业五机房（一）\n\n'
            '面向对象程序设计及实践B\n李朝鹏(副教授)\n6-9周[03-04节]\n专业五机房（一）\n\n'
            '面向对象程序设计及实践B\n李朝鹏(副教授)\n10-13周[03-04节]\n专业五机房（一）',
      },
      <String, Object?>{
        'weekday': 4,
        'period': 3,
        'span': 2,
        'name': '',
        'parts': <Object?>[],
        'text': '面向对象程序设计及实践B\n李朝鹏(副教授)\n2-5周[05-06节]\n专业五机房（一）\n\n'
            '面向对象程序设计及实践B\n李朝鹏(副教授)\n6-9周[05-06节]\n专业五机房（一）\n\n'
            '面向对象程序设计及实践B\n李朝鹏(副教授)\n10-13周[05-06节]\n专业五机房（一）',
      },
      <String, Object?>{
        'weekday': 1,
        'period': 3,
        'span': 2,
        'name': '',
        'parts': <Object?>[],
        'text': '习近平新时代中国特色社会主义思想概论\n'
            '康珏(助教（高校）),唐芳云(副教授)\n2-17周[05-06节]\n致远-320',
      },
      <String, Object?>{
        'weekday': 5,
        'period': 3,
        'span': 2,
        'name': '',
        'parts': <Object?>[],
        'text': '信号与系统\n刘湛(讲师（高校）)\n2-15周[05-06节]\n百全-103',
      },
      <String, Object?>{
        'weekday': 1,
        'period': 4,
        'span': 2,
        'name': '',
        'parts': <Object?>[],
        'text': '信号与系统\n刘湛(讲师（高校）)\n2-15周[07-08节]\n百全-103',
      },
    ];

class _FakeStorage implements TimetableStorage {
  Map<String, dynamic>? data;

  @override
  Future<Map<String, dynamic>?> readJson() async => data;

  @override
  Future<void> writeJson(Map<String, dynamic> json) async => data = json;

  @override
  Future<void> clear() async => data = null;
}
