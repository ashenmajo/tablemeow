//app_update_info.dart
//服务器返回的更新信息：最新版本号、下载地址与更新说明

import 'package:flutter/foundation.dart';

import '../utils/version_compare.dart';

@immutable
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.downloadUrl,
    this.notes = '',
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    final String version = _textOf(json['version']);
    final String downloadUrl = _textOf(json['download_url']);
    if (version.isEmpty) {
      throw const FormatException('缺少 version 字段');
    }
    if (downloadUrl.isEmpty) {
      throw const FormatException('缺少 download_url 字段');
    }
    return AppUpdateInfo(
      version: version,
      downloadUrl: downloadUrl,
      notes: _textOf(json['notes']),
    );
  }

  final String version;

  final String downloadUrl;

  final String notes;

  Uri? get downloadUri {
    final Uri? uri = Uri.tryParse(downloadUrl);
    return uri != null && uri.hasScheme ? uri : null;
  }

  bool isNewerThan(String currentVersion) =>
      compareAppVersions(version, currentVersion) > 0;

  static String _textOf(Object? value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.trim();
    }
    return value.toString().trim();
  }
}
