import 'package:shared_preferences/shared_preferences.dart';

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
