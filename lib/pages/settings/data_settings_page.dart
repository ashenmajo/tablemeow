//data_setting_page.dart
//该文件是数据管理页
//可以删除课表数据和导入课表产生的网页数据

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../state/app_scope.dart';
import '../../state/app_state.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section_card.dart';
import '../../pages/settings/timetable_data_show.dart';

class DataSettingsPage extends StatelessWidget {
  const DataSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AppScope.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('数据管理')),
      body: PageScaffold(
        children: <Widget>[
          SectionCard(
            title: '课表',
            icon: Icons.storage_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('课表数据'),
                  subtitle: Text(
                    '${state.sessions.length} 条上课安排 · '
                    '${state.timetable.courseCount} 门课程 · '
                    '约 ${_sizeOf(state)}',
                  ),
                  onTap: () =>
                      _open(context, TimetableDataShow(sorted: state.sessions)),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    '清空课表',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: const Text('保留学期与外观设置'),
                  enabled: state.sessions.isNotEmpty,
                  onTap: () => _clearTimetable(context, state),
                ),
              ],
            ),
          ),
          SectionCard(
            title: '网页数据',
            icon: Icons.public_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  '登录教务系统时应用会打开真实网页，'
                  '浏览器的缓存与登录状态可能占用几十 MB。'
                  '课表本身很小，占空间的主要是这部分。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _clearWebData(context),
                  icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                  label: const Text('清除网页数据'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  /// 课表 JSON 的大小，让用户知道课表本身占不了多少。
  static String _sizeOf(AppState state) {
    final int bytes = utf8.encode(jsonEncode(state.timetable.toJson())).length;
    if (bytes < 1024) {
      return '$bytes B';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  Future<void> _clearWebData(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool confirmed = await _confirm(
      context,
      title: '清除网页数据',
      content: '会清掉教务系统的登录状态与页面缓存，下次导入需要重新登录。',
      confirmLabel: '清除',
    );
    if (!confirmed) {
      return;
    }
    if (WebViewPlatform.instance == null) {
      _toast(messenger, '当前平台没有网页登录，无需清理');
      return;
    }
    try {
      await WebViewCookieManager().clearCookies();
      final WebViewController controller = WebViewController();
      await controller.clearCache();
      await controller.clearLocalStorage();
      _toast(messenger, '已清除网页数据');
    } catch (error) {
      _toast(messenger, '清除失败：$error');
    }
  }

  void _toast(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _clearTimetable(BuildContext context, AppState state) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool confirmed = await _confirm(
      context,
      title: '清空课表',
      content: '将删除全部 ${state.sessions.length} 条上课安排。',
      confirmLabel: '清空',
    );
    if (!confirmed) {
      return;
    }
    await state.clearSessions();
    _toast(messenger, '课表已清空');
  }
}
