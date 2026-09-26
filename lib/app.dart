import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data/timetable_storage.dart';
import 'models/timetable_style.dart';
import 'navigation/home_shell.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class TableMeowApp extends StatefulWidget {
  const TableMeowApp({super.key, this.storage, this.clock});

  /// 课表存储，默认走 shared_preferences。
  final TimetableStorage? storage;

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
            home: HomeShell(),
          );
        },
      ),
    );
  }
}
