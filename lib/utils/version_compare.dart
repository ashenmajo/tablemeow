//version_compare.dart
//比较版本号，用于判断服务器上的版本是否比本机新

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

String displayVersion(String version) {
  final String text = version.trim();
  if (text.isEmpty) {
    return '未知版本';
  }
  final bool prefixed = text.startsWith('v') || text.startsWith('V');
  return prefixed ? 'v${text.substring(1)}' : 'v$text';
}

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

int _numberOf(String segment) {
  final Match? match = RegExp(r'\d+').firstMatch(segment);
  if (match == null) {
    return 0;
  }
  return int.tryParse(match.group(0)!) ?? 0;
}
