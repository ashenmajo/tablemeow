import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// 把 [AppState] 提供给整棵子树，状态变化时自动刷新依赖它的界面。
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final AppScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope?.notifier != null, 'AppScope.of() 需要在 AppScope 子树中使用');
    return scope!.notifier!;
  }
}
