import 'package:flutter/material.dart';

import '../models/timetable_style.dart';

/// 应用的 Material 3 Expressive 主题。
///
/// 界面层只使用 [AppTheme.light] 与 [AppTheme.dark]，
/// 配色由种子色推导；组件风格（大圆角、tonal 按钮、导航栏指示器）
/// 走 Material 3 Expressive 的写法。
abstract final class AppTheme {
  /// 种子色：靛蓝。导航栏、按钮、卡片、输入框都从这一套配色推导。
  ///
  /// 这里用 [DynamicSchemeVariant.tonalSpot]（Material 3 基线算法），
  /// 它能保住种子色的色相；`expressive` 变体会把色相转到绿色去。
  /// 换种子色前建议先跑一遍 `flutter test --update-goldens` 看实际效果。
  static const Color defaultSeed = Color(TimetableStyle.defaultSeedColor);

  /// 卡片、弹窗等大圆角，体现 Expressive 的形状风格。
  static const double _largeRadius = 20;

  static ThemeData light({Color seedColor = defaultSeed}) =>
      _build(Brightness.light, seed: seedColor);

  /// [oled] 为真时走纯黑背景，适合 OLED 屏。
  static ThemeData dark({bool oled = false, Color seedColor = defaultSeed}) =>
      _build(Brightness.dark, seed: seedColor, oled: oled);

  /// 把设置里的主题模式映射成 Flutter 的 [ThemeMode]。
  static ThemeMode modeOf(AppThemeMode mode) => switch (mode) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };

  /// 纯黑模式：背景全黑，容器用极深的灰分层。
  static ColorScheme _blackedIf(ColorScheme base, bool oled) {
    if (!oled) {
      return base;
    }
    return base.copyWith(
      surface: const Color(0xFF000000),
      surfaceContainerLowest: const Color(0xFF000000),
      surfaceContainerLow: const Color(0xFF080808),
      surfaceContainer: const Color(0xFF0E0E0E),
      surfaceContainerHigh: const Color(0xFF161616),
      surfaceContainerHighest: const Color(0xFF1E1E1E),
      onSurface: const Color(0xFFE8E8EA),
      onSurfaceVariant: const Color(0xFFB4B4B8),
      outlineVariant: const Color(0xFF2A2A2E),
    );
  }

  static ThemeData _build(
    Brightness brightness, {
    Color seed = defaultSeed,
    bool oled = false,
  }) {
    final ColorScheme colorScheme = _blackedIf(
      ColorScheme.fromSeed(
        seedColor: seed,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
      ),
      oled,
    );
    final BorderRadius radius = BorderRadius.circular(_largeRadius);

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarThemeData(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
