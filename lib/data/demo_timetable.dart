import '../models/course_session.dart';

/// 内置示例课表：界面预览与测试用的固定数据。
///
/// 周次覆盖第 1-18 周，其中包含单双周与周六的课程。
List<CourseSession> demoCourseSessions() {
  final List<int> allWeeks = _weeks(1, 18);
  final List<int> oddWeeks = _weeks(1, 18, step: 2);
  final List<int> evenWeeks = _weeks(2, 18, step: 2);

  return <CourseSession>[
    CourseSession(
      name: '高等数学 A',
      weekday: 1,
      startPeriod: 1,
      endPeriod: 2,
      weeks: allWeeks,
      teacher: '王建国',
      location: '教一 101',
    ),
    CourseSession(
      name: '大学英语',
      weekday: 1,
      startPeriod: 3,
      endPeriod: 4,
      weeks: allWeeks,
      teacher: 'Linda',
      location: '外语楼 305',
    ),
    CourseSession(
      name: '程序设计基础',
      weekday: 1,
      startPeriod: 5,
      endPeriod: 6,
      weeks: oddWeeks,
      teacher: '陈晓',
      location: '机房 A203',
    ),
    CourseSession(
      name: '数据结构',
      weekday: 2,
      startPeriod: 1,
      endPeriod: 2,
      weeks: allWeeks,
      teacher: '李慕白',
      location: '教二 208',
    ),
    CourseSession(
      name: '线性代数',
      weekday: 2,
      startPeriod: 3,
      endPeriod: 4,
      weeks: allWeeks,
      teacher: '赵敏',
      location: '教一 305',
    ),
    CourseSession(
      name: '计算机组成原理',
      weekday: 2,
      startPeriod: 7,
      endPeriod: 8,
      weeks: allWeeks,
      teacher: '周航',
      location: '教二 112',
    ),
    CourseSession(
      name: '体育（羽毛球）',
      weekday: 3,
      startPeriod: 3,
      endPeriod: 4,
      weeks: allWeeks,
      teacher: '刘洋',
      location: '体育馆',
    ),
    CourseSession(
      name: '操作系统',
      weekday: 3,
      startPeriod: 5,
      endPeriod: 6,
      weeks: allWeeks,
      teacher: '孙立',
      location: '教二 401',
    ),
    CourseSession(
      name: '大学物理',
      weekday: 4,
      startPeriod: 1,
      endPeriod: 2,
      weeks: allWeeks,
      teacher: '郑明',
      location: '理科楼 501',
    ),
    CourseSession(
      name: '离散数学',
      weekday: 4,
      startPeriod: 3,
      endPeriod: 4,
      weeks: allWeeks,
      teacher: '吴桐',
      location: '教一 207',
    ),
    CourseSession(
      name: '数据结构实验',
      weekday: 4,
      startPeriod: 7,
      endPeriod: 8,
      weeks: evenWeeks,
      teacher: '李慕白',
      location: '机房 A105',
    ),
    CourseSession(
      name: '马克思主义基本原理',
      weekday: 5,
      startPeriod: 1,
      endPeriod: 2,
      weeks: allWeeks,
      teacher: '何静',
      location: '教三 101',
    ),
    CourseSession(
      name: '计算机网络',
      weekday: 5,
      startPeriod: 3,
      endPeriod: 4,
      weeks: allWeeks,
      teacher: '张伟',
      location: '教二 306',
    ),
    CourseSession(
      name: '创新创业实践',
      weekday: 6,
      startPeriod: 1,
      endPeriod: 3,
      weeks: _weeks(2, 14, step: 2),
      teacher: '马赛',
      location: '创客空间',
    ),
  ];
}

/// 生成 [from] 到 [to]（含）的周次列表，[step] 为步长。
List<int> _weeks(int from, int to, {int step = 1}) {
  return <int>[for (int week = from; week <= to; week += step) week];
}
