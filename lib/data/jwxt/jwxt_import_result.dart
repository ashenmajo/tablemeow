import '../../models/course_session.dart';

/// 网页登录导入的结果。
class JwxtImportResult {
  const JwxtImportResult({required this.sessions, this.warning = ''});

  /// 读取到的上课安排。
  final List<CourseSession> sessions;

  /// 结果可能不完整时的提醒，例如页面只显示了某一周。
  final String warning;

  bool get isEmpty => sessions.isEmpty;
}
