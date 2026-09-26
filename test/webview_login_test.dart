import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/app.dart';
import 'package:tablemeow/data/jwxt/jwxt_login_store.dart';
import 'package:tablemeow/data/timetable_storage.dart';
import 'package:tablemeow/pages/webview_login_page.dart';

void main() {
  // 测试跑在桌面宿主上，没有注册 WebView 实现，
  // 正好用来验证「不支持网页登录」这条分支的提示与降级。
  testWidgets('非移动端会说明网页登录不可用', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WebViewLoginPage(initialUrl: 'https://jw.example.edu.cn'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前平台不支持网页登录'), findsOneWidget);
    expect(find.textContaining('粘贴导入'), findsOneWidget);
  });

  testWidgets('导入页在非移动端禁用网页登录并给出提示', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      TableMeowApp(
        storage: MemoryTimetableStorage(),
        loginStore: MemoryJwxtLoginStore(),
        clock: () => DateTime(2026, 3, 11, 10, 0),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('导入'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('登录教务系统'), findsOneWidget);
    expect(
      find.textContaining('当前平台不支持应用内网页登录'),
      findsOneWidget,
    );

    final FilledButton button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '打开登录页'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('会回填上次使用的登录地址', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final MemoryJwxtLoginStore store = MemoryJwxtLoginStore(
      'https://vpn.example.edu.cn',
    );
    await tester.pumpWidget(
      TableMeowApp(
        storage: MemoryTimetableStorage(),
        loginStore: store,
        clock: () => DateTime(2026, 3, 11, 10, 0),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('导入'),
      ),
    );
    await tester.pumpAndSettle();

    final TextField urlField = tester.widget<TextField>(
      find.byType(TextField).first,
    );
    expect(urlField.controller?.text, 'https://vpn.example.edu.cn');
  });
}
