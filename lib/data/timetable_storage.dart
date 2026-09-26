import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 课表持久化接口。
///
/// 生产环境使用 [SharedPreferencesTimetableStorage]。
abstract interface class TimetableStorage {
  Future<Map<String, dynamic>?> readJson();

  Future<void> writeJson(Map<String, dynamic> json);

  Future<void> clear();
}

/// 基于 shared_preferences 的课表存储。
class SharedPreferencesTimetableStorage implements TimetableStorage {
  static const String storageKey = 'tablemeow.timetable.v1';

  @override
  Future<Map<String, dynamic>?> readJson() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(raw);
      return decoded is Map ? decoded.cast<String, dynamic>() : null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> writeJson(Map<String, dynamic> json) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(json));
  }

  @override
  Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
