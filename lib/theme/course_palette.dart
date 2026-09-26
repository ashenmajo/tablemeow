import 'package:flutter/material.dart';

import '../models/timetable_style.dart';

/// 课程块配色。
///
/// 默认「跟随主题色」：直接取主题配色里的容器色，天然与主色协调，
/// 也符合 Material 3 的色调规范；换主色时整张课表跟着变。
/// 单门课单独指定的颜色优先级最高。
abstract final class CoursePalette {
  /// 内置色板，仅在「自定义色板」模式下使用。
  static const Map<CoursePaletteKind, List<Color>> palettes =
      <CoursePaletteKind, List<Color>>{
        CoursePaletteKind.material: <Color>[
          Color(0xFFD7E3FF),
          Color(0xFFE2DAF7),
          Color(0xFFCDE8E5),
          Color(0xFFF5DEDC),
          Color(0xFFDDE6D5),
          Color(0xFFF4E3C8),
        ],
        CoursePaletteKind.macaron: <Color>[
          Color(0xFFFDE2E4),
          Color(0xFFE2ECE9),
          Color(0xFFDDE7F3),
          Color(0xFFF7E4CC),
          Color(0xFFE8E6F5),
          Color(0xFFFBE7EF),
        ],
        CoursePaletteKind.morandi: <Color>[
          Color(0xFFE6E2DC),
          Color(0xFFD9E0DC),
          Color(0xFFDDE0E6),
          Color(0xFFE8DED8),
          Color(0xFFDCDCD2),
          Color(0xFFE4DEE4),
        ],
        CoursePaletteKind.contrast: <Color>[
          Color(0xFFBBD3FF),
          Color(0xFFFFD9A8),
          Color(0xFFA8E6D0),
          Color(0xFFFFC2C2),
          Color(0xFFD9C7FF),
          Color(0xFFFFE08A),
        ],
      };

  /// 「跟随主题色」用的容器色：都由主色推导，互相之间是协调的。
  ///
  /// 容器的明度随亮暗模式自动切换，格子上再叠加自动对比的文字色，
  /// 亮暗两种模式下都能读。
  static List<Color> themeColors(ColorScheme scheme) => <Color>[
    scheme.primaryContainer,
    scheme.secondaryContainer,
    scheme.tertiaryContainer,
    scheme.surfaceContainerHighest,
    scheme.primaryFixedDim,
    scheme.tertiaryFixedDim,
    scheme.secondaryFixedDim,
    scheme.primaryFixed,
  ];

  /// 单色模式下用的颜色（跟着主题走）。
  static Color singleColor(ColorScheme scheme) => scheme.secondaryContainer;

  /// 详情页里可以直接点选的颜色，用来给某门课单独指定。
  static List<Color> swatchesFor(ColorScheme scheme) => <Color>[
    ...themeColors(scheme),
    ...palettes[CoursePaletteKind.material]!,
    ...palettes[CoursePaletteKind.macaron]!,
  ];

  static Color surface(
    String name,
    TimetableStyle style,
    ColorScheme scheme,
  ) {
    final int? custom = style.courseColors[name];
    if (custom != null) {
      return Color(custom);
    }
    if (style.colorMode == CourseColorMode.single) {
      return singleColor(scheme);
    }
    final List<Color> palette = style.colorMode == CourseColorMode.custom
        ? palettes[style.palette] ?? palettes[CoursePaletteKind.material]!
        : themeColors(scheme);
    return palette[_indexOf(name, palette.length)];
  }

  static Color onSurface(
    String name,
    TimetableStyle style,
    ColorScheme scheme,
  ) {
    switch (style.textColor) {
      case CourseTextColor.dark:
        return const Color(0xFF1B1B1F);
      case CourseTextColor.light:
        return const Color(0xFFF4F4F6);
      case CourseTextColor.auto:
        final Color background = surface(name, style, scheme);
        return ThemeData.estimateBrightnessForColor(background) ==
                Brightness.dark
            ? const Color(0xFFF4F4F6)
            : const Color(0xFF1B1B1F);
    }
  }

  static int _indexOf(String name, int length) {
    if (name.isEmpty) {
      return 0;
    }
    int hash = 7;
    for (final int rune in name.runes) {
      hash = (hash * 31 + rune) & 0x7fffffff;
    }
    return hash % length;
  }
}
