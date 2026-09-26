import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/jwxt/jwxt_import_result.dart';
import '../data/jwxt/jwxt_login_store.dart';
import '../models/course_session.dart';
import '../models/semester.dart';
import '../navigation/app_destination.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../widgets/labeled_field.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section_card.dart';
import 'webview_login_page.dart';

/// 导入页：打开学校登录页显式登录后读取课表。
class ImportPage extends StatefulWidget {
  const ImportPage({super.key, this.loginStore});

  /// 登录地址的存储实现，为空时使用 shared_preferences。
  final JwxtLoginStore? loginStore;

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  late final JwxtLoginStore _loginStore =
      widget.loginStore ?? SharedPreferencesJwxtLoginStore();

  final TextEditingController _urlController = TextEditingController();

  final String _term = '3';
  String? _error;

  @override
  void initState() {
    super.initState();
    _restoreLoginUrl();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _restoreLoginUrl() async {
    final String? saved = await _loginStore.readLoginUrl();
    if (!mounted || saved == null) {
      return;
    }
    _urlController.text = saved;
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('导入课表')),
      body: PageScaffold(
        description:
            '打开学校登录页自己登录，'
            '登录后在教务系统中进入「学期理论课表」页面点「读取课表」即可导入。',
        children: <Widget>[_buildLoginCard(state)],
      ),
    );
  }

  Widget _buildLoginCard(AppState state) {
    final ThemeData theme = Theme.of(context);
    final bool webLoginAvailable = WebViewPlatform.instance != null;

    return SectionCard(
      title: '登录教务系统',
      subtitle: '在应用内打开真实登录页，登录后自动读取课表',
      icon: Icons.school_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          LabeledField(
            label: '登录地址',
            child: TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: '请填入教务系统地址',
                prefixIcon: Icon(Icons.link),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: webLoginAvailable ? () => _openLogin(state) : null,
            icon: const Icon(Icons.open_in_browser),
            label: const Text('打开登录页'),
          ),
          if (!webLoginAvailable) ...<Widget>[
            const SizedBox(height: 12),
            _MessageBanner(
              icon: Icons.public_off_outlined,
              message: '当前平台不支持应用内网页登录，请在手机上使用本功能。',
              color: theme.colorScheme.error,
            ),
          ],
          if (_error != null) ...<Widget>[
            const SizedBox(height: 12),
            _MessageBanner(
              icon: Icons.error_outline,
              message: _error!,
              color: theme.colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openLogin(AppState state) async {
    final String url = _urlController.text.trim();
    final Uri? parsed = Uri.tryParse(url);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      setState(() => _error = '请填写完整的登录地址，例如 https://jw.example.edu.cn');
      return;
    }

    setState(() => _error = null);
    await _loginStore.writeLoginUrl(url);

    if (!mounted) {
      return;
    }
    final JwxtImportResult? result = await Navigator.of(context)
        .push<JwxtImportResult>(
          MaterialPageRoute<JwxtImportResult>(
            builder: (BuildContext context) => WebViewLoginPage(
              initialUrl: url,
              term: _term,
              totalWeeks: state.semester.totalWeeks,
            ),
          ),
        );
    if (result == null || result.isEmpty || !mounted) {
      return;
    }
    final String warning = <String>[
      if (result.warning.isNotEmpty) result.warning,
      if (_semesterStartLooksDefault(state)) _semesterStartHint,
    ].join('；');
    await _applySessions(state, result.sessions, warning: warning);
  }

  static const String _semesterStartHint =
      '课表日期按本机学期设置推算，请到「设置」把第 1 周周一改成开学第一周的周一';

  static bool _semesterStartLooksDefault(AppState state) {
    final DateTime thisMonday = Semester.mondayOf(state.now);
    return state.semester.startDate == thisMonday;
  }

  Future<void> _applySessions(
    AppState state,
    List<CourseSession> sessions, {
    String warning = '',
  }) async {
    await state.importSessions(sessions);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    final courseCount = sessions
        .map((CourseSession s) {
          return s.name;
        })
        .toSet()
        .length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: warning.isEmpty
            ? const Duration(seconds: 4)
            : const Duration(seconds: 6),
        content: Text('已导入 $courseCount门课'),
      ),
    );
    state.openTab(AppTab.timetable);
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
