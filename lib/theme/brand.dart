///brand.dart
///该文件放品牌固定色：这些颜色不随主题明暗变化。
library;

import 'package:flutter/material.dart';

abstract final class Brand {
  /// 应用图标的 indigo 底色，取自 android 的 ic_launcher.png。
  /// 品牌图的白色图形需要一块深色底才看得见，所以关于页的页头固定用它，
  /// 不跟随主题的 primary —— 深色主题下 primary 是很浅的淡紫，白图会糊在上面。
  static const Color indigo = Color(0xFF3F50B5);
}
