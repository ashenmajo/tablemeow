import 'package:shared_preferences/shared_preferences.dart';

/// 记录上次使用的教务 / VPN 登录地址，避免每次重新输入。
abstract interface class JwxtLoginStore {
  Future<String?> readLoginUrl();

  Future<void> writeLoginUrl(String url);
}

class SharedPreferencesJwxtLoginStore implements JwxtLoginStore {
  static const String storageKey = 'tablemeow.jwxt.loginUrl.v1';

  @override
  Future<String?> readLoginUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? value = prefs.getString(storageKey);
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<void> writeLoginUrl(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, url);
  }
}

/// 只存在内存里的实现，用于测试。
class MemoryJwxtLoginStore implements JwxtLoginStore {
  MemoryJwxtLoginStore([this._url]);

  String? _url;

  String? get url => _url;

  @override
  Future<String?> readLoginUrl() async => _url;

  @override
  Future<void> writeLoginUrl(String url) async => _url = url;
}
