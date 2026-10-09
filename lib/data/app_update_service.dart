// app_update_service.dart
// 从服务器获取信息

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_update_info.dart';

class AppUpdateException implements Exception {
  AppUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppUpdateService {
  AppUpdateService({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint = endpoint ?? Uri.parse('http://47.97.11.221/api/check');

  final http.Client _client;
  final Uri _endpoint;

  static const _timeout = Duration(seconds: 12);

  Future<AppUpdateInfo> fetchLatest() async {
    http.Response resp;
    try {
      resp = await _client
          .get(_endpoint, headers: {'Accept': 'application/json'})
          .timeout(_timeout);
    } on TimeoutException {
      throw AppUpdateException('连接超时，检查下网络');
    } catch (e) {
      throw AppUpdateException('连不上更新服务器：$e');
    }

    if (resp.statusCode != 200) {
      throw AppUpdateException('服务器返回 ${resp.statusCode}');
    }

    dynamic data;
    try {
      data = jsonDecode(utf8.decode(resp.bodyBytes));
    } catch (_) {
      throw AppUpdateException('返回的不是合法 JSON');
    }

    if (data is! Map) {
      throw AppUpdateException('返回结构不对，期望是对象');
    }

    try {
      return AppUpdateInfo.fromJson(Map<String, dynamic>.from(data));
    } on FormatException catch (e) {
      throw AppUpdateException('字段有问题：${e.message}');
    }
  }
}
