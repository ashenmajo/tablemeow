import 'package:flutter/material.dart';

/// 内容页统一骨架：说明文字 + 限宽、可滚动的区块列表。
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    this.description,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
    this.controller,
  });

  /// 页面顶部的一句说明，省略时不占位。
  final String? description;
  final List<Widget> children;
  final EdgeInsets padding;
  final ScrollController? controller;

  static const double _maxContentWidth = 720;
  static const double _gap = 16;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      controller: controller,
      padding: padding,
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (description != null) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: _gap),
                    child: Text(
                      description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
                ..._spaced(children),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 在相邻区块之间插入统一间距。
  List<Widget> _spaced(List<Widget> children) {
    return <Widget>[
      for (int index = 0; index < children.length; index++) ...<Widget>[
        if (index > 0) const SizedBox(height: _gap),
        children[index],
      ],
    ];
  }
}
