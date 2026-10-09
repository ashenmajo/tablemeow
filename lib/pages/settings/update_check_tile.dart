///update_check_tile.dart
///设置页最下面的「检测更新」入口：请求更新接口、弹窗展示结果、跳转下载页
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_info.dart';
import '../../data/app_update_service.dart';
import '../../models/app_update_info.dart';
import '../../utils/version_compare.dart';

class UpdateCheckTile extends StatefulWidget {
  const UpdateCheckTile({
    super.key,
    this.source,
    this.currentVersion,
    this.launcher,
  });

  final AppUpdateService? source;

  final String? currentVersion;

  final Future<bool> Function(Uri url)? launcher;

  @override
  State<UpdateCheckTile> createState() => _UpdateCheckTileState();
}

class _UpdateCheckTileState extends State<UpdateCheckTile> {
  bool _checking = false;

  String get _currentVersion => widget.currentVersion ?? AppInfo.version;

  AppUpdateService get _source => widget.source ?? AppUpdateService();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.system_update_alt),
      title: const Text('检测更新'),
      subtitle: Text(
        _checking ? '正在检测…' : '当前版本 ${displayVersion(_currentVersion)}',
      ),
      trailing: _checking
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.chevron_right),
      onTap: _checking ? null : _check,
    );
  }

  Future<void> _check() async {
    if (_checking) {
      return;
    }
    setState(() => _checking = true);
    try {
      final AppUpdateInfo info = await _source.fetchLatest();
      if (!mounted) {
        return;
      }
      setState(() => _checking = false);
      await _showResult(info);
    } on AppUpdateException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _checking = false);
      _showFailure(error.message);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _checking = false);
      _showFailure('检测更新失败:$error');
    }
  }

  Future<void> _showResult(AppUpdateInfo info) async {
    if (!info.isNewerThan(_currentVersion)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('当前已是最新版本'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final bool download = await _showDownloadDialog(info);
    if (!mounted) {
      return;
    }
    if (download) {
      await _openDownload(info);
    }
  }

  Future<bool> _showDownloadDialog(AppUpdateInfo info) async {
    final ThemeData theme = Theme.of(context);
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        //icon: const Icon(Icons.new_releases_outlined),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text('发现新版本 ${displayVersion(info.version)}')],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(info.notes, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('稍后'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.download_outlined, size: 18),
            label: const Text('前往下载'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showFailure(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _openDownload(AppUpdateInfo info) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final Uri? uri = info.downloadUri;
    if (uri == null) {
      messenger.showSnackBar(
        SnackBar(content: Text('下载地址不可用：${info.downloadUrl}')),
      );
      return;
    }
    bool opened = false;
    try {
      opened = await (widget.launcher ?? _launchExternally)(uri);
    } catch (_) {
      opened = false;
    }
    if (!opened) {
      messenger.showSnackBar(
        SnackBar(content: Text('打不开浏览器，请手动访问：${info.downloadUrl}')),
      );
    }
  }

  static Future<bool> _launchExternally(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);
}
