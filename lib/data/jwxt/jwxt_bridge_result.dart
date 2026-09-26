import 'dart:convert';

import 'jwxt_web_scripts.dart';

/// WebView 里脚本通过 JS 通道回传的结果。
class JwxtBridgeResult {
  const JwxtBridgeResult({
    required this.status,
    this.message = '',
    this.source = '',
    this.body = '',
    this.courses = const <Object?>[],
    this.schoolYear = '',
    this.term = '',
    this.token = '',
    this.warning = '',
  });

  /// [JwxtWebScripts.statusOk] 或 [JwxtWebScripts.statusError]。
  final String status;

  /// 失败原因，可直接展示给用户。
  final String message;

  /// 数据来源：教务系统接口或页面表格。
  final String source;

  /// 接口返回的原始响应体。
  final String body;

  /// 页面表格抓到的课程条目。
  final List<Object?> courses;

  /// 实际使用的学年与学期，便于在界面上回显。
  final String schoolYear;
  final String term;

  /// 请求标识：由宿主在注入脚本时生成，脚本原样回传。
  ///
  /// 用来丢弃上一次请求迟到的回包，避免两次读取的结果串在一起。
  final String token;

  /// 读取成功但结果可能不完整时的提醒（例如页面只显示了某一周）。
  final String warning;

  bool get isOk => status == JwxtWebScripts.statusOk;

  /// 解析脚本回传的 JSON，无法识别时返回 null。
  static JwxtBridgeResult? tryDecode(String raw) {
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      final Map<String, dynamic> map = decoded.cast<String, dynamic>();
      final String status = map['status'] as String? ?? '';
      if (status.isEmpty) {
        return null;
      }
      return JwxtBridgeResult(
        status: status,
        message: map['message'] as String? ?? '',
        source: map['source'] as String? ?? '',
        body: map['body'] as String? ?? '',
        courses: map['courses'] as List<Object?>? ?? const <Object?>[],
        schoolYear: map['schoolYear']?.toString() ?? '',
        term: map['term']?.toString() ?? '',
        token: map['token']?.toString() ?? '',
        warning: map['warning']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}
