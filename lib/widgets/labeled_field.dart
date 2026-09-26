import 'package:flutter/material.dart';

/// 带独立标题的输入框：标题固定显示在输入框上方，而不是浮在框内和内容挤在一起。
///
/// 用法是把 [TextField] 的 `labelText` 换成 `hintText`，再交给这个组件包一层。
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.helper,
  });

  /// 输入框上方的标题。
  final String label;

  final Widget child;

  /// 输入框下方的补充说明，可省略。
  final String? helper;

  static const EdgeInsets _labelPadding = EdgeInsets.only(left: 4, bottom: 6);
  static const EdgeInsets _helperPadding = EdgeInsets.only(left: 4, top: 6);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final TextStyle? helperStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: _labelPadding,
          child: Text(label, style: labelStyle),
        ),
        child,
        if (helper != null)
          Padding(
            padding: _helperPadding,
            child: Text(helper!, style: helperStyle),
          ),
      ],
    );
  }
}
