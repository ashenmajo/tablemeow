import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data/jwxt/jwxt_login_store.dart';
import 'data/timetable_storage.dart';
import 'models/timetable_style.dart';
import 'navigation/home_shell.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

/// 应用根组件。
///
/// 负责三件事：注入课表存储与时间来源、读取本地课表、
/// 把 [AppState] 通过 [AppScope] 交给整棵子树，
/// 并让主题跟着设置里的主色 / 明暗 / 纯黑一起变。
class TableMeowApp extends StatefulWidget {
  const TableMeowApp({super.key, this.storage, this.loginStore, this.clock});

  /// 课表存储，默认走 shared_preferences。
  final TimetableStorage? storage;

  /// 教务系统登录地址存储，默认走 shared_preferences。
  final JwxtLoginStore? loginStore;

  /// 时间来源，测试可以注入固定时间。
  final DateTime Function()? clock;

  @override
  State<TableMeowApp> createState() => _TableMeowAppState();
}

class _TableMeowAppState extends State<TableMeowApp> {
  late final AppState _state = AppState(
    storage: widget.storage ?? SharedPreferencesTimetableStorage(),
    clock: widget.clock,
  );

  @override
  void initState() {
    super.initState();
    _state.load();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: AnimatedBuilder(
        animation: _state,
        builder: (BuildContext context, Widget? _) {
          final TimetableStyle style = _state.style;
          return MaterialApp(
            title: 'TableMeow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(seedColor: style.seedColor).copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: <TargetPlatform, PageTransitionsBuilder>{
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme:
                AppTheme.dark(
                  oled: style.oledBlack,
                  seedColor: style.seedColor,
                ).copyWith(
                  pageTransitionsTheme: const PageTransitionsTheme(
                    builders: <TargetPlatform, PageTransitionsBuilder>{
                      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                    },
                  ),
                ),
            themeMode: AppTheme.modeOf(style.themeMode),
            home: HomeShell(loginStore: widget.loginStore),
          );
        },
      ),
    );
  }
}
