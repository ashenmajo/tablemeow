import 'package:flutter/material.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.helper,
  });

  final String label;

  final Widget child;

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
