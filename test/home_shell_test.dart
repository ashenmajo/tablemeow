import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/app.dart';
import 'package:tablemeow/data/demo_timetable.dart';
import 'package:tablemeow/data/jwxt/jwxt_login_store.dart';
import 'package:tablemeow/data/timetable_storage.dart';
import 'package:tablemeow/models/semester.dart';
import 'package:tablemeow/models/timetable.dart';
import 'package:tablemeow/widgets/timetable_grid.dart';

void main() {
  // 固定在第 2 周周三上午，课表与今日页都会有课。
  DateTime fixedNow() => DateTime(2026, 3, 11, 10, 0);

  /// 示例课表当作已导入的数据写进存储。
  MemoryTimetableStorage demoStorage() => MemoryTimetableStorage(
    Timetable(
      semester: Semester(startDate: DateTime(2026, 3, 9), totalWeeks: 20),
      sessions: demoCourseSessions(),
    ).toJson(),
  );

  Future<void> pumpApp(
    WidgetTester tester, {
    MemoryTimetableStorage? storage,
    Size size = const Size(1080, 1920),
    DateTime Function()? clock,
  }) async {
    // 默认测试画布只有 800x600，放大后页面元素才不会被挤出可视区。
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      TableMeowApp(
        storage: storage ?? MemoryTimetableStorage(),
        loginStore: MemoryJwxtLoginStore(),
        clock: clock ?? fixedNow,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('没有课表时展示空状态，并用底部导航切换页面', (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDrawer), findsNothing);
    expect(find.text('还没有课表数据'), findsOneWidget);

    await openTab(tester, '设置');
    expect(find.text('节次时间'), findsOneWidget);

    await openTab(tester, '导入');
    expect(find.text('登录教务系统'), findsOneWidget);
    // 导入页只保留教务系统导入，粘贴导入与示例区块都已移除。
    expect(find.text('粘贴导入'), findsNothing);
    expect(find.text('载入示例'), findsNothing);
    expect(find.text('示例与清理'), findsNothing);
  });

  testWidgets('冷启动时直接显示当前周（不是第一周）', (WidgetTester tester) async {
    // 2026-03-25 落在第 3 周；课表第一周从 2026-03-09 开始。
    await pumpApp(
      tester,
      storage: demoStorage(),
      clock: () => DateTime(2026, 3, 25, 10, 0),
    );

    expect(find.text('第 3 周'), findsOneWidget);
    // 表头日期也要是第 3 周的（3/23 周一），说明网格真的翻到了第 3 页。
    expect(find.text('3/23'), findsOneWidget);
    expect(find.text('3/9'), findsNothing);
  });

  testWidgets('有课表时展示周课表与课程块', (WidgetTester tester) async {
    await pumpApp(tester, storage: demoStorage());

    expect(find.text('课程表'), findsOneWidget);
    expect(find.text('第 1 周'), findsOneWidget);
    expect(find.text('高等数学 A'), findsWidgets);
    // 教室拆成「楼名 + 房间号」两段渲染，方便在两者之间换行。
    expect(find.text('教一'), findsWidgets);
    expect(find.text('101'), findsWidgets);
    // 周末没课也保留周六、周日两列。
    expect(find.text('周六'), findsOneWidget);
    expect(find.text('周日'), findsOneWidget);
  });

  testWidgets('切换周次后课程随之变化', (WidgetTester tester) async {
    await pumpApp(tester, storage: demoStorage());

    await tester.tap(find.byTooltip('下一周'));
    await tester.pumpAndSettle();
    expect(find.text('第 2 周'), findsOneWidget);
    // 第 2 周周六有「创新创业实践」。
    expect(find.text('创新创业实践'), findsWidgets);

    await tester.tap(find.byTooltip('上一周'));
    await tester.pumpAndSettle();
    expect(find.text('第 1 周'), findsOneWidget);
    expect(find.text('创新创业实践'), findsNothing);
  });

  testWidgets('左右滑动课表可以切换周次', (WidgetTester tester) async {
    // 手机宽度：7 列正好铺满，横向不用滚动，滑动交给 PageView 翻页。
    await pumpApp(tester, storage: demoStorage(), size: const Size(400, 860));
    expect(find.text('第 1 周'), findsOneWidget);

    // 向左快滑 → 下一周。
    await tester.fling(
      find.byType(TimetableGrid).first,
      const Offset(-200, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('第 2 周'), findsOneWidget);

    // 向右快滑 → 回到上一周。
    await tester.fling(
      find.byType(TimetableGrid).first,
      const Offset(200, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('第 1 周'), findsOneWidget);
  });

  testWidgets('长按课表不再打开设置', (WidgetTester tester) async {
    await pumpApp(tester, storage: demoStorage());

    await tester.longPress(find.byType(TimetableGrid).first);
    await tester.pumpAndSettle();

    expect(find.text('课表样式'), findsNothing);
    expect(find.text('显示网格线'), findsNothing);
  });

  testWidgets('设置里可以进课表外观并调整', (WidgetTester tester) async {
    final MemoryTimetableStorage storage = demoStorage();
    await pumpApp(tester, storage: storage);
    await openTab(tester, '设置');

    // 外观按用途拆成了几个入口。
    expect(find.text('布局与尺寸'), findsOneWidget);
    expect(find.text('配色'), findsOneWidget);
    expect(find.text('显示内容'), findsOneWidget);
    expect(find.text('主题'), findsWidgets);

    await tester.tap(find.text('布局与尺寸'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('layout-preview')),
      findsOneWidget,
    );
    expect(find.byType(TimetableGrid), findsNWidgets(2));
    expect(find.text('字号缩放'), findsOneWidget);
    expect(find.text('密度预设'), findsOneWidget);

    // 预设会立即更新预览并持久化。
    await tester.tap(find.widgetWithText(ChoiceChip, '紧凑').first);
    await tester.pumpAndSettle();
    expect((storage.json!['style'] as Map)['courseBlockRadius'], 6.0);

    await tester.fling(find.byType(ListView), const Offset(0, -700), 1000);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('layout-preview-floating')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey<String>('layout-preview-floating')),
          )
          .width,
      lessThan(
        tester
            .getSize(find.byKey(const ValueKey<String>('layout-preview')))
            .width,
      ),
    );
    final Material floatingPreview = tester.widget<Material>(
      find
          .ancestor(
            of: find.byKey(
              const ValueKey<String>('layout-preview-floating-content'),
            ),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(floatingPreview.elevation, 8);

    // 关掉网格线后立刻写入存储。
    final Finder gridSwitch = find.widgetWithText(SwitchListTile, '显示网格线');
    await Scrollable.ensureVisible(tester.element(gridSwitch), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(gridSwitch);
    await tester.pumpAndSettle();

    final Map<String, dynamic>? saved = storage.json;
    expect(saved, isNotNull);
    expect((saved!['style'] as Map)['showGrid'], isFalse);
  });

  testWidgets('配色与主题各在自己的页面里', (WidgetTester tester) async {
    await pumpApp(tester, storage: demoStorage());
    await openTab(tester, '设置');

    await tester.tap(find.text('配色'));
    await tester.pumpAndSettle();
    expect(find.text('配色方案'), findsOneWidget);
    // 默认跟随主题色，这时不显示色板。
    expect(find.text('跟随主题色'), findsOneWidget);
    expect(find.text('色板'), findsNothing);

    // 切到自定义色板后才出现色板选择。
    await tester.tap(find.text('自定义色板'));
    await tester.pumpAndSettle();
    expect(find.text('色板'), findsOneWidget);
    expect(find.text('莫兰迪'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('显示内容'));
    await tester.pumpAndSettle();
    expect(find.text('显示地点'), findsOneWidget);
    expect(find.text('去掉教师职称'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('主题').last);
    await tester.pumpAndSettle();
    expect(find.text('跟随系统'), findsOneWidget);
    expect(find.text('纯黑模式'), findsOneWidget);
    expect(find.text('主色'), findsOneWidget);
  });

  testWidgets('设置里的分类可以进到子页面', (WidgetTester tester) async {
    await pumpApp(tester, storage: demoStorage());
    await openTab(tester, '设置');

    await tester.tap(find.text('节次时间'));
    await tester.pumpAndSettle();
    expect(find.text('每节课的时间'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('学期设置'));
    await tester.pumpAndSettle();
    expect(find.text('起始与周数'), findsOneWidget);
    expect(find.text('第 1 周周一'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('数据管理'));
    await tester.pumpAndSettle();
    expect(find.text('课表数据'), findsOneWidget);
    expect(find.text('清空课表'), findsOneWidget);
    expect(find.text('清除网页数据'), findsOneWidget);
  });

  testWidgets('回到应用时自动跳回本周', (WidgetTester tester) async {
    await pumpApp(tester, storage: demoStorage());
    expect(find.text('第 1 周'), findsOneWidget);

    // 手动翻到第 3 周。
    await tester.tap(find.byTooltip('下一周'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('下一周'));
    await tester.pumpAndSettle();
    expect(find.text('第 3 周'), findsOneWidget);

    // 模拟切到后台再回来（生命周期要走完整条链）。
    for (final AppLifecycleState state in <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
      await tester.pumpAndSettle();
    }

    expect(find.text('第 1 周'), findsOneWidget);
  });

  testWidgets('节次时间可以一键重排', (WidgetTester tester) async {
    final MemoryTimetableStorage storage = demoStorage();
    await pumpApp(tester, storage: storage);
    await openTab(tester, '设置');
    await tester.tap(find.text('节次时间'));
    await tester.pumpAndSettle();

    // 自动调整在节次列表上方。
    expect(find.text('自动调整'), findsOneWidget);
    expect(find.text('上午开始'), findsOneWidget);
    expect(find.text('下午开始'), findsOneWidget);
    expect(find.text('每节时长'), findsOneWidget);
    expect(find.text('课间休息'), findsOneWidget);

    // 默认 45 分钟 / 10 分钟：第 3 节从 10:00 变成 09:50。
    await tester.tap(find.text('按上面参数重排节次'));
    await tester.pumpAndSettle();

    final Map<String, dynamic> semester = (storage.json!['semester'] as Map)
        .cast<String, dynamic>();
    final List<Object?> periods = semester['periods']! as List<Object?>;
    expect(((periods[2] as Map)['start']), '09:50');
    expect(((periods[2] as Map)['end']), '10:35');
  });

  testWidgets('今日页列出当天课程', (WidgetTester tester) async {
    await pumpApp(tester, storage: demoStorage());
    await openTab(tester, '今日');

    expect(find.text('3月11日 周三'), findsOneWidget);
    expect(find.text('第 1 周 · 共 2 节课'), findsOneWidget);
    expect(find.text('体育（羽毛球）'), findsWidgets);
    expect(find.text('操作系统'), findsWidgets);

    // 课程按节次排序：第 3-4 节在前，第 5-6 节在后。
    expect(
      tester.getTopLeft(find.text('体育（羽毛球）')).dy,
      lessThan(tester.getTopLeft(find.text('操作系统')).dy),
    );
    // 10:00 正在上第 3-4 节，徽章应显示进行中。
    expect(find.textContaining('进行中'), findsOneWidget);
  });

  testWidgets('课程详情里可以改显示名称', (WidgetTester tester) async {
    final MemoryTimetableStorage storage = demoStorage();
    await pumpApp(tester, storage: storage);

    await tester.tap(find.text('高等数学 A').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('课表上显示的名字'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.enterText(find.byType(TextField), '高数');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    // 弹窗关掉后不应再抛异常（控制器由弹窗自己销毁）。
    expect(tester.takeException(), isNull);
    final Map<String, dynamic> style = (storage.json!['style'] as Map)
        .cast<String, dynamic>();
    expect((style['courseAliases'] as Map)['高等数学 A'], '高数');
  });

  testWidgets('课程详情里可以单独指定颜色与别名', (WidgetTester tester) async {
    final MemoryTimetableStorage storage = demoStorage();
    await pumpApp(tester, storage: storage);

    await tester.tap(find.text('高等数学 A').first);
    await tester.pumpAndSettle();
    expect(find.text('课程颜色'), findsOneWidget);
    // 颜色不是直接铺一排，而是点开才选。
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.text('课程颜色'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    // 选第一个色块。
    await tester.tap(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pumpAndSettle();

    final Map<String, dynamic>? saved = storage.json;
    final Map<String, dynamic> style = (saved!['style'] as Map)
        .cast<String, dynamic>();
    expect((style['courseColors'] as Map).containsKey('高等数学 A'), isTrue);
  });

  testWidgets('点击课程块弹出详情', (WidgetTester tester) async {
    await pumpApp(tester, storage: demoStorage());

    await tester.tap(find.text('高等数学 A').first);
    await tester.pumpAndSettle();

    expect(find.text('上课周次'), findsOneWidget);
    expect(find.text('1-18周'), findsOneWidget);
    expect(find.text('王建国'), findsWidgets);
  });
}
