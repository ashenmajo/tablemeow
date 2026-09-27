import '../../models/course_session.dart';

class JwxtImportResult {
  const JwxtImportResult({required this.sessions, this.warning = ''});

  final List<CourseSession> sessions;

  /// 结果不完整时的提醒，例如页面只显示了某一周。
  final String warning;

  bool get isEmpty => sessions.isEmpty;
}
