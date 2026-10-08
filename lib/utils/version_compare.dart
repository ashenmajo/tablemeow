///version_compare.dart
///比较版本号，用于判断服务器上的版本是否比本机新
library;

/// 比较两个版本号：[a] 比 [b] 新返回正数，相同返回 0，比 [b] 旧返回负数。
///
/// 忽略开头的 `v`、构建号（`+1`）与预发布后缀（`-beta`），逐段按数字比较，
/// 缺失的段按 0 处理，所以 `1.0` 与 `1.0.0` 一样新。
int compareAppVersions(String a, String b) {
  final List<int> left = _segmentsOf(a);
  final List<int> right = _segmentsOf(b);
  final int length = left.length > right.length ? left.length : right.length;
  for (int index = 0; index < length; index++) {
    final int x = index < left.length ? left[index] : 0;
    final int y = index < right.length ? right[index] : 0;
    if (x != y) {
      return x > y ? 1 : -1;
    }
  }
  return 0;
}

/// 展示用的版本号：`1.0.0`、`v1.0.0` 都写成 `v1.0.0`，空值写成「未知版本」。
String displayVersion(String version) {
  final String text = version.trim();
  if (text.isEmpty) {
    return '未知版本';
  }
  final bool prefixed = text.startsWith('v') || text.startsWith('V');
  return prefixed ? 'v${text.substring(1)}' : 'v$text';
}

/// 去掉前缀与后缀后，把 `1.2.3` 拆成 `[1, 2, 3]`。
List<int> _segmentsOf(String version) {
  String text = version.trim();
  if (text.startsWith('v') || text.startsWith('V')) {
    text = text.substring(1);
  }
  final int plus = text.indexOf('+');
  if (plus >= 0) {
    text = text.substring(0, plus);
  }
  final int dash = text.indexOf('-');
  if (dash >= 0) {
    text = text.substring(0, dash);
  }
  return text.split('.').map(_numberOf).toList();
}

/// 取出这一段里的数字，取不到（例如空串）就当 0，避免解析失败直接崩掉。
int _numberOf(String segment) {
  final Match? match = RegExp(r'\d+').firstMatch(segment);
  if (match == null) {
    return 0;
  }
  return int.tryParse(match.group(0)!) ?? 0;
}
