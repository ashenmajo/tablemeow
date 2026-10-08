///app_update_service.dart
///访问更新接口，把服务器返回的 JSON 变成 AppUpdateInfo
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_update_info.dart';

class AppUpdateException implements Exception {
  const AppUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract interface class AppUpdateSource {
  Future<AppUpdateInfo> fetchLatest();
}

class HttpAppUpdateSource implements AppUpdateSource {
  HttpAppUpdateSource({
    http.Client? client,
    Uri? endpoint,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client(),
       endpoint = endpoint ?? defaultEndpoint;

  static final Uri defaultEndpoint = Uri.parse('http://47.97.11.221/api/check');

  final http.Client _client;

  final Uri endpoint;

  final Duration timeout;

  @override
  Future<AppUpdateInfo> fetchLatest() async {
    return await _fetch(endpoint);
  }

  Future<AppUpdateInfo> _fetch(Uri endpoint) async {
    final http.Response response;
    try {
      response = await _client
          .get(
            endpoint,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const AppUpdateException('连接更新服务器超时，请检查网络后重试');
    } catch (_) {
      throw const AppUpdateException('无法连接更新服务器，请检查网络后重试');
    }

    if (response.statusCode != 200) {
      throw AppUpdateException('更新服务器返回异常（HTTP ${response.statusCode}）');
    }

    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw const AppUpdateException('更新信息格式不正确，请联系开发者');
    }
    if (decoded is! Map) {
      throw const AppUpdateException('更新信息格式不正确，请联系开发者');
    }

    try {
      return AppUpdateInfo.fromJson(decoded.cast<String, dynamic>());
    } on FormatException catch (error) {
      throw AppUpdateException('更新信息不完整（${error.message}），请联系开发者');
    }
  }
}
