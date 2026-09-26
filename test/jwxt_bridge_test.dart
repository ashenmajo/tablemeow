import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/data/jwxt/jwxt_bridge_result.dart';
import 'package:tablemeow/data/jwxt/jwxt_course_parser.dart';
import 'package:tablemeow/data/jwxt/jwxt_web_scripts.dart';
import 'package:tablemeow/models/course_session.dart';

void main() {
  group('脚本回传结果', () {
    test('解析接口结果', () {
      final JwxtBridgeResult? result = JwxtBridgeResult.tryDecode(
        '{"status":"ok","source":"api","schoolYear":"2025","term":"3",'
        '"body":"[{\\"kcmc\\":\\"高等数学\\"}]"}',
      );

      expect(result, isNotNull);
      expect(result!.isOk, isTrue);
      expect(result.isFromApi, isTrue);
      expect(result.schoolYear, '2025');
      expect(result.term, '3');
      expect(result.body, contains('高等数学'));
    });

    test('解析页面表格结果', () {
      final JwxtBridgeResult? result = JwxtBridgeResult.tryDecode(
        '{"status":"ok","source":"document","courses":['
        '{"weekday":1,"period":1,"span":2,"text":"高等数学\\n王建国\\n教一101\\n1-16周"}]}',
      );

      expect(result, isNotNull);
      expect(result!.isFromDocument, isTrue);
      expect(result.courses, hasLength(1));
    });

    test('解析失败结果', () {
      final JwxtBridgeResult? result = JwxtBridgeResult.tryDecode(
        '{"status":"error","message":"当前页面没有找到课表表格"}',
      );

      expect(result, isNotNull);
      expect(result!.isOk, isFalse);
      expect(result.message, contains('课表表格'));
    });

    test('无法识别的消息返回 null', () {
      expect(JwxtBridgeResult.tryDecode('not json'), isNull);
      expect(JwxtBridgeResult.tryDecode('{"foo":1}'), isNull);
      expect(JwxtBridgeResult.tryDecode('[]'), isNull);
    });

    test('带回请求 token，用于区分不同次读取', () {
      final JwxtBridgeResult? result = JwxtBridgeResult.tryDecode(
        '{"status":"ok","source":"api","token":"tm-1","body":"[]"}',
      );

      expect(result, isNotNull);
      expect(result!.token, 'tm-1');
      expect(
        JwxtBridgeResult.tryDecode('{"status":"ok"}')!.token,
        isEmpty,
      );
    });

    test('带回读取不完整的提醒', () {
      final JwxtBridgeResult? result = JwxtBridgeResult.tryDecode(
        '{"status":"ok","source":"document","courses":[],'
        '"warning":"页面当前只显示了第3周"}',
      );

      expect(result, isNotNull);
      expect(result!.warning, '页面当前只显示了第3周');
      expect(JwxtBridgeResult.tryDecode('{"status":"ok"}')!.warning, isEmpty);
    });
  });

  group('页面表格单元格解析', () {
    const JwxtCourseParser parser = JwxtCourseParser(totalWeeks: 20);

    test('解析典型的「课程 / 教师 / 教室 / 周次」单元格', () {
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 1,
        'period': 1,
        'span': 2,
        'text': '高等数学\n王建国\n教一101\n1-16周',
      });

      expect(session, isNotNull);
      expect(session!.name, '高等数学');
      expect(session.weekday, 1);
      expect(session.startPeriod, 1);
      expect(session.endPeriod, 2);
      expect(session.teacher, '王建国');
      expect(session.location, '教一101');
      expect(session.weeks, hasLength(16));
    });

    test('周次夹在课程名括号里也能识别', () {
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 3,
        'period': 3,
        'span': 1,
        'text': '大学英语(1-16周(单))\nLinda\n外语楼305',
      });

      expect(session, isNotNull);
      expect(session!.name, '大学英语');
      expect(session.weeks, <int>[1, 3, 5, 7, 9, 11, 13, 15]);
      expect(session.teacher, 'Linda');
      expect(session.location, '外语楼305');
      expect(session.endPeriod, 3);
    });

    test('缺少姓名时按含数字区分教室', () {
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 5,
        'period': 7,
        'span': 3,
        'text': '创新创业实践\n创客空间\n2-14周(双)',
      });

      expect(session, isNotNull);
      expect(session!.name, '创新创业实践');
      expect(session.endPeriod, 9);
      expect(session.weeks, <int>[2, 4, 6, 8, 10, 12, 14]);
      // 「创客空间」不含数字，会被当成教师名，这是可接受的启发式结果。
      expect(session.teacher, '创客空间');
      expect(session.location, isEmpty);
    });

    test('强智单元格：周次写在括号里、节次写在单元格里', () {
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 1,
        'period': 1,
        'span': 1,
        'text': '电磁场与电磁波\n侯周国\n副教授\n2-11(周)\n[01-02]节\n致远-501',
      });

      expect(session, isNotNull);
      expect(session!.name, '电磁场与电磁波');
      expect(session.weekday, 1);
      // 单元格写明了节次，比「一行一个节次」的推断更准。
      expect((session.startPeriod, session.endPeriod), (1, 2));
      expect(session.weeks, <int>[2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
      // 职称不算教师名。
      expect(session.teacher, '侯周国');
      expect(session.location, '致远-501');
    });

    test('强智单元格：地点是纯中文楼名时也能认出来', () {
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 4,
        'period': 2,
        'span': 1,
        'text': '嵌入式系统\n谢玮\n高等学校教师\n8-11(周)\n[01-02]节\n公共机房四',
      });

      expect(session, isNotNull);
      expect(session!.teacher, '谢玮');
      expect(session.location, '公共机房四');
      expect(session.weeks, <int>[8, 9, 10, 11]);
    });

    test('字段挤在同一行时按空格拆分', () {
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 2,
        'period': 3,
        'span': 1,
        'text': '数据库应用 张三 1-16(周) [03-04]节 一教101',
      });

      expect(session, isNotNull);
      expect(session!.name, '数据库应用');
      expect((session.startPeriod, session.endPeriod), (3, 4));
      expect(session.teacher, '张三');
      expect(session.location, '一教101');
      expect(session.weeks, hasLength(16));
    });

    test('带 title 的字段（强智）优先用来取教师与教室', () {
      // 这些字段之间没有任何分隔符，innerText 会粘成一整串，
      // 所以脚本会额外回传 `标题\u0001内容`。
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 1,
        'period': 1,
        'span': 1,
        'text': '电磁场与电磁波侯周国副教授2-11(周)\n[01-02]节致远-501',
        'name': '电磁场与电磁波',
        'parts': <String>[
          '老师\u0001侯周国',
          '老师\u0001副教授',
          '周次(节次)\u00012-11(周)\n[01-02]节',
          '教室\u0001致远-501',
        ],
      });

      expect(session, isNotNull);
      expect(session!.name, '电磁场与电磁波');
      expect(session.teacher, '侯周国');
      expect(session.location, '致远-501');
      expect(session.weeks, <int>[2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);
      expect((session.startPeriod, session.endPeriod), (1, 2));
    });

    test('强智把课程名重复几遍时只留第一遍', () {
      // 这些字符串是从真机「查看明细」里抄下来的。
      final List<String> cases = <String>[
        '电磁场与电磁波 电磁场与电磁波(理论:40',
        '习近平新时代中国特色社会主义思想概论 习近平新时代中国特色社会主义思想概论(理论:32',
        '信号与系统 信号与系统(理论:56,实践:8',
      ];
      for (final String raw in cases) {
        final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
          'weekday': 1,
          'period': 1,
          'span': 1,
          'text': '$raw\n1-16周',
        });
        expect(session, isNotNull, reason: raw);
        expect(session!.name, raw.split(' ').first, reason: raw);
      }
    });

    test('强智用短横线分隔理论与实践时只取第一段', () {
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 1,
        'period': 3,
        'span': 1,
        'text': '面向对象程序设计及实践 B-----------------'
            '面向对象程序设计及实践B(理论:32,实践:16)-----------------'
            '面向对象程序设计及实践B((理论:32,实践:16),理论:32,实践:16)'
            '\n2-5周',
      });

      expect(session, isNotNull);
      expect(session!.name.startsWith('面向对象程序设计及实践'), isTrue);
      expect(session.name.contains('---'), isFalse);
      expect(session.weeks, <int>[2, 3, 4, 5]);
    });

    test('教师名后面的职称与括注都摘掉', () {
      const JwxtCourseParser parser = JwxtCourseParser();
      CourseSession? parse(String teacher) => parser.parseScrapedItem(
        <String, dynamic>{
          'weekday': 1,
          'period': 1,
          'span': 1,
          'text': '信号与系统\n$teacher\n1-16周',
        },
      );

      expect(parse('刘湛讲师（高校）')!.teacher, '刘湛');
      expect(parse('谢玮高等学校教师')!.teacher, '谢玮');
      expect(parse('侯周国')!.teacher, '侯周国');
    });

    test('强智「大节」单元格：周次与节次写在同一行', () {
      // 截图里的真实结构：一个格子 = 一个大节，周次后面紧跟节次。
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 2,
        'period': 1,
        'span': 1,
        'text': '嵌入式系统\n谢玮高等学校教师\n14-17(周)[01-02]节\n公共机房四',
      });

      expect(session, isNotNull);
      expect(session!.name, '嵌入式系统');
      expect(session.weeks, <int>[14, 15, 16, 17]);
      expect((session.startPeriod, session.endPeriod), (1, 2));
      // 教师名后面的职称要摘掉。
      expect(session.teacher, '谢玮');
      expect(session.location, '公共机房四');
    });

    test('强智「备注」行里的课不导入', () {
      expect(
        parser.parseScrapedItem(<String, dynamic>{
          'weekday': 1,
          'period': 6,
          'span': 1,
          'text': '备注：嵌入式系统课程设计 刘菡 17-18周;',
        }),
        isNull,
      );
    });

    test('只有节次信息时覆盖整个学期', () {
      final CourseSession? session = parser.parseScrapedItem(<String, dynamic>{
        'weekday': 2,
        'period': 5,
        'span': 1,
        'text': '数据结构\n[05-06]节',
      });

      expect(session, isNotNull);
      expect(session!.weeks, hasLength(20));
      expect(session.teacher, isEmpty);
    });

    test('没有任何排课信息的格子会被跳过', () {
      // 学习通网课之类的占位格既没有周次也没有节次，不该进课表。
      expect(
        parser.parseScrapedItem(<String, dynamic>{
          'weekday': 1,
          'period': 1,
          'span': 1,
          'text': '学习通：大学语文',
        }),
        isNull,
      );
      expect(
        parser.parseScrapedItem(<String, dynamic>{
          'weekday': 1,
          'period': 1,
          'span': 1,
          'text': '军事理论（慕课）',
        }),
        isNull,
      );
    });

    test('缺少星期或节次时丢弃', () {
      expect(
        parser.parseScrapedItem(<String, dynamic>{'period': 1, 'text': '课程'}),
        isNull,
      );
      expect(
        parser.parseScrapedItem(<String, dynamic>{'weekday': 1, 'text': '课程'}),
        isNull,
      );
      expect(
        parser.parseScrapedItem(<String, dynamic>{
          'weekday': 9,
          'period': 1,
          'text': '课程',
        }),
        isNull,
      );
    });

    test('只有周次没有课程名时丢弃', () {
      expect(
        parser.parseScrapedItem(<String, dynamic>{
          'weekday': 1,
          'period': 1,
          'text': '1-16周',
        }),
        isNull,
      );
    });

    test('一次解析多条单元格', () {
      final List<CourseSession> sessions = parser.parseScrapedCourses(
        <Object?>[
          <String, dynamic>{
            'weekday': 1,
            'period': 1,
            'span': 2,
            'text': '高等数学\n1-16周',
          },
          <String, dynamic>{
            'weekday': 2,
            'period': 3,
            'span': 1,
            'text': '线性代数\n1-16周',
          },
          'invalid',
          <String, dynamic>{'weekday': 0, 'period': 1, 'text': '异常数据\n1-16周'},
        ],
      );

      expect(sessions, hasLength(2));
      expect(sessions.first.name, '高等数学');
      expect(sessions.last.name, '线性代数');
    });
  });

  group('注入脚本', () {
    test('通道名、token 与兜底参数被写入脚本', () {
      final String script = JwxtWebScripts.fetchTimetable(
        fallbackSchoolYear: '2025',
        fallbackTerm: '12',
        token: 'tm-42',
      );

      expect(script, contains(JwxtWebScripts.bridgeChannel));
      expect(script, contains('"2025"'));
      expect(script, contains('"12"'));
      expect(script, contains('"tm-42"'));
      expect(script, isNot(contains('__CHANNEL__')));
      expect(script, isNot(contains('__TOKEN__')));
      expect(script, isNot(contains('__XNM__')));
      expect(script, isNot(contains('__XQM__')));
      expect(script, contains('xskbcx_cxXsKb'));
    });

    test('接口脚本会连 iframe 一起找学年学期', () {
      final String script = JwxtWebScripts.fetchTimetable();

      expect(script, contains('contentDocument'));
      expect(script, contains('iframe,frame'));
    });

    test('接口脚本不会把 HTML 登录页当成课表结果', () {
      final String script = JwxtWebScripts.fetchTimetable();

      expect(script, contains('没有返回课表数据'));
      expect(script, contains('xhr.status >= 400'));
    });

    test('表格抓取脚本按表头打分找课表，不依赖厂商的表格 id', () {
      final String script = JwxtWebScripts.scrapeDocument(token: 'tm-7');

      expect(script, contains(JwxtWebScripts.bridgeChannel));
      expect(script, contains('"tm-7"'));
      expect(script, isNot(contains('__CHANNEL__')));
      expect(script, isNot(contains('__TOKEN__')));
      expect(script, contains('timetableScore'));
      expect(script, contains("querySelectorAll('table')"));
      expect(script, contains('rowSpan'));
      expect(script, contains('contentDocument'));
      expect(script, contains('colSpan'));
    });

    test('页面只筛了某一周时会自动去取全部周次', () {
      final String script = JwxtWebScripts.scrapeDocument();

      expect(script, contains('weekFilterOf'));
      expect(script, contains('全部'));
      expect(script, contains('DOMParser'));
      expect(script, contains('weekRequestOf'));
    });
  });
}
