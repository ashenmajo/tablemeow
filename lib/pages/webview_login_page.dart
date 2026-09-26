import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/jwxt/jwxt_bridge_result.dart';
import '../data/jwxt/jwxt_course_parser.dart';
import '../data/jwxt/jwxt_import_result.dart';
import '../data/jwxt/jwxt_web_scripts.dart';
import '../models/course_session.dart';

/// 显式登录页：把学校真实的登录页面放进 WebView，由用户自己完成登录。
///
/// 这样 VPN 跳转、统一身份认证、验证码等都不需要单独适配；
/// 登录完成后借用 WebView 里已有的会话去读取课表，
/// 读取成功的课程列表通过 [Navigator.pop] 返回给调用方。
class WebViewLoginPage extends StatefulWidget {
  const WebViewLoginPage({
    super.key,
    required this.initialUrl,
    this.schoolYear = '',
    this.term = '3',
    this.totalWeeks = 20,
  });

  /// 首次打开的地址，可以是 VPN 地址，也可以是教务系统地址。
  final String initialUrl;

  /// 兜底学年与学期：页面上读不到选项时使用。
  final String schoolYear;
  final String term;

  final int totalWeeks;

  @override
  State<WebViewLoginPage> createState() => _WebViewLoginPageState();
}

class _WebViewLoginPageState extends State<WebViewLoginPage> {
  WebViewController? _controller;

  JwxtCourseParser get _parser => JwxtCourseParser(
    totalWeeks: widget.totalWeeks,
  );

  Completer<JwxtBridgeResult>? _pending;

  /// 当前这次请求的标识，用来忽略上一次请求迟到的回包。
  String _pendingToken = '';
  int _runSeq = 0;

  final List<String> _attemptErrors = <String>[];

  /// 最近一次接口里读到的学年学期，用于失败时提示。
  String _scope = '';

  /// 读取成功但结果可能不完整时的提醒。
  String _warning = '';

  double _progress = 0;
  String _title = '';
  String? _status;
  String? _error;
  bool _busy = false;

  /// 当前平台是否提供 WebView 实现（桌面端与测试环境没有）。
  late final bool _supported = WebViewPlatform.instance != null;

  @override
  void initState() {
    super.initState();
    _title = widget.initialUrl;
    if (_supported) {
      _controller = _buildController()..loadRequest(Uri.parse(widget.initialUrl));
    }
  }

  WebViewController _buildController() {
    // 先声明再配置：导航回调里需要引用 controller 本身。
    final WebViewController controller = WebViewController();
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        JwxtWebScripts.bridgeChannel,
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() => _progress = progress / 100);
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _progress = 0;
                _error = null;
              });
            }
          },
          onPageFinished: (String url) => _syncTitle(controller),
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame ?? false) {
              if (mounted) {
                setState(() => _error = '页面加载失败：${error.description}');
              }
            }
          },
        ),
      );
    return controller;
  }

  Future<void> _syncTitle(WebViewController controller) async {
    try {
      final String? title = await controller.getTitle();
      if (!mounted || title == null || title.trim().isEmpty) {
        return;
      }
      setState(() => _title = title.trim());
    } catch (_) {
      // 取标题失败不影响使用，忽略。
    }
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    final JwxtBridgeResult? result = JwxtBridgeResult.tryDecode(message.message);
    final Completer<JwxtBridgeResult>? pending = _pending;
    if (result == null || pending == null || pending.isCompleted) {
      return;
    }
    if (result.token != _pendingToken) {
      // 上一次请求迟到的回包，丢掉，避免串到这一次的结果上。
      return;
    }
    pending.complete(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          if (_supported)
            IconButton(
              tooltip: '刷新',
              onPressed: () => _controller?.reload(),
              icon: const Icon(Icons.refresh),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _supported ? _buildWebView() : const _UnsupportedPlatform(),
      bottomNavigationBar: _supported
          ? _buildBottomBar(context)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildWebView() {
    final WebViewController? controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: <Widget>[
        if (_progress < 1)
          LinearProgressIndicator(
            value: _progress == 0 ? null : _progress,
            minHeight: 3,
          ),
        if (_status != null)
          _Banner(
            icon: Icons.downloading_outlined,
            message: _status!,
            color: Theme.of(context).colorScheme.primary,
          ),
        if (_error != null)
          _Banner(
            icon: Icons.error_outline,
            message: _error!,
            color: Theme.of(context).colorScheme.error,
          ),
        Expanded(child: WebViewWidget(controller: controller)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '请在下方页面完成登录（VPN 与教务系统可能各需要一次），'
              '打开课表查询页面（正方「学生课表查询」/ 强智「学期理论课表」）后点右侧按钮。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _controller?.reload,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('刷新'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _fetchTimetable,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.playlist_add_check, size: 18),
                    label: Text(_busy ? '读取中…' : '已完成登录，读取课表'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 先请求课表接口，读不到再退化为抓取当前页面的课表表格。
  Future<void> _fetchTimetable() async {
    if (_busy || _controller == null) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _status = '正在读取课表…';
    });
    _attemptErrors.clear();
    _scope = '';
    _warning = '';

    try {
      List<CourseSession> sessions = await _fetchFromApi();
      if (sessions.isEmpty) {
        if (mounted) {
          setState(() => _status = '接口没有读到课表，改为读取页面上的表格…');
        }
        sessions = await _fetchFromDocument();
      }

      if (sessions.isEmpty) {
        if (mounted) {
          setState(() {
            _status = null;
            _error = _attemptErrors.isEmpty
                ? _emptyMessage
                : _attemptErrors.toSet().take(2).join('；');
          });
        }
        return;
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        JwxtImportResult(sessions: sessions, warning: _warning),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _status = null;
        });
      }
    }
  }

  String get _emptyMessage {
    final String scope = _scope.isEmpty ? '' : '（$_scope）';
    return '没有读取到课表$scope，请确认已登录并打开了课表查询页面';
  }

  /// 把正方接口里的学期编号翻译成可读文本。
  static String _termLabel(String term) {
    switch (term) {
      case '3':
        return '第一学期';
      case '12':
        return '第二学期';
      case '16':
        return '第三学期';
      default:
        return term.isEmpty ? '' : '学期 $term';
    }
  }

  Future<List<CourseSession>> _fetchFromApi() async {
    final JwxtBridgeResult? result = await _runScript(
      (String token) => JwxtWebScripts.fetchTimetable(
        fallbackSchoolYear: widget.schoolYear,
        fallbackTerm: widget.term,
        token: token,
      ),
    );
    if (result == null) {
      return const <CourseSession>[];
    }
    if (result.schoolYear.isNotEmpty || result.term.isNotEmpty) {
      _scope = '${result.schoolYear} 学年${_termLabel(result.term)}';
    }
    final List<CourseSession> sessions = _parser.parseResponse(result.body);
    if (sessions.isEmpty) {
      _attemptErrors.add(
        '课表接口没有返回课程${_scope.isEmpty ? '' : '（$_scope）'}，'
        '请确认教务系统里选中的学年学期与课表查询页面一致',
      );
    }
    return sessions;
  }

  Future<List<CourseSession>> _fetchFromDocument() async {
    final JwxtBridgeResult? result = await _runScript(
      (String token) => JwxtWebScripts.scrapeDocument(token: token),
    );
    if (result == null) {
      return const <CourseSession>[];
    }
    if (result.warning.isNotEmpty) {
      _warning = result.warning;
    }
    return _parser.parseScrapedCourses(result.courses);
  }

  /// 执行脚本并等待它通过 JS 通道回传结果。
  ///
  /// [build] 会拿到本次请求的 token 并生成脚本，脚本回包时必须带回同样的
  /// token，否则会被 [_onBridgeMessage] 丢掉。
  Future<JwxtBridgeResult?> _runScript(
    String Function(String token) build, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final WebViewController? controller = _controller;
    if (controller == null) {
      return null;
    }
    final String token =
        'tm-${DateTime.now().microsecondsSinceEpoch}-${_runSeq++}';
    final Completer<JwxtBridgeResult> completer =
        Completer<JwxtBridgeResult>();
    _pending = completer;
    _pendingToken = token;
    try {
      try {
        await controller.runJavaScript(build(token));
      } catch (error) {
        _attemptErrors.add('执行页面脚本失败：$error');
        return null;
      }
      final JwxtBridgeResult result = await completer.future.timeout(timeout);
      // 脚本自己报了失败：记下原因，并按「没拿到结果」返回，
      // 这样两个调用方不用各写一遍这段判断。
      if (!result.isOk) {
        if (result.message.isNotEmpty) {
          _attemptErrors.add(result.message);
        }
        return null;
      }
      return result;
    } on TimeoutException {
      _attemptErrors.add('读取超时，请确认页面已完全加载并处于登录状态');
      return null;
    } finally {
      if (identical(_pending, completer)) {
        _pending = null;
        _pendingToken = '';
      }
    }
  }
}

/// 桌面端等没有 WebView 实现的平台。
class _UnsupportedPlatform extends StatelessWidget {
  const _UnsupportedPlatform();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.public_off_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('当前平台不支持网页登录', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '网页登录目前只在 Android / iOS 上可用。'
              '在其他平台上请改用「粘贴导入」，'
              '或先在手机上打开一次登录页。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withValues(alpha: 0.12),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
