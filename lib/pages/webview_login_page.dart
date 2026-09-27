///webview_login_page.dart
///该文件是导入课表页
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/jwxt/jwxt_bridge_result.dart';
import '../data/jwxt/jwxt_course_parser.dart';
import '../data/jwxt/jwxt_import_result.dart';
import '../data/jwxt/jwxt_web_scripts.dart';
import '../models/course_session.dart';

class WebViewLoginPage extends StatefulWidget {
  const WebViewLoginPage({
    super.key,
    required this.initialUrl,
    this.totalWeeks = 20,
  });

  final String initialUrl;

  final int totalWeeks;

  @override
  State<WebViewLoginPage> createState() => _WebViewLoginPageState();
}

class _WebViewLoginPageState extends State<WebViewLoginPage> {
  WebViewController? _controller;

  JwxtCourseParser get _parser =>
      JwxtCourseParser(totalWeeks: widget.totalWeeks);

  Completer<JwxtBridgeResult>? _pending;

  String _pendingToken = '';
  int _runSeq = 0;

  final List<String> _attemptErrors = <String>[];

  String _scope = '';

  String _warning = '';

  double _progress = 0;
  String _title = '';
  String? _status;
  String? _error;
  bool _busy = false;

  late final bool _supported = WebViewPlatform.instance != null;

  @override
  void initState() {
    super.initState();
    _title = widget.initialUrl;
    if (_supported) {
      _controller = _buildController()
        ..loadRequest(Uri.parse(widget.initialUrl));
    }
  }

  WebViewController _buildController() {
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
      // 读取标题失败
    }
  }

  void _onBridgeMessage(JavaScriptMessage message) {
    final JwxtBridgeResult? result = JwxtBridgeResult.tryDecode(
      message.message,
    );
    final Completer<JwxtBridgeResult>? pending = _pending;
    if (result == null || pending == null || pending.isCompleted) {
      return;
    }
    if (result.token != _pendingToken) {
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
      Navigator.of(context)
          .pop(JwxtImportResult(sessions: sessions, warning: _warning));
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
      (String token) => JwxtWebScripts.fetchTimetable(token: token),
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
    final Completer<JwxtBridgeResult> completer = Completer<JwxtBridgeResult>();
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
              '网页登录目前只在 Android / iOS 上可用',
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
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
