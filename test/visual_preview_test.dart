import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tablemeow/app.dart';
import 'package:tablemeow/data/demo_timetable.dart';
import 'package:tablemeow/data/jwxt/jwxt_login_store.dart';
import 'package:tablemeow/data/timetable_storage.dart';
import 'package:tablemeow/models/semester.dart';
import 'package:tablemeow/models/timetable.dart';

void main() {
  DateTime fixedNow() => DateTime(2026, 3, 11, 10, 0);

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final MemoryTimetableStorage storage = MemoryTimetableStorage(
      Timetable(
        semester: Semester(startDate: DateTime(2026, 3, 9), totalWeeks: 20),
        sessions: demoCourseSessions(),
      ).toJson(),
    );
    await tester.pumpWidget(
      TableMeowApp(
        storage: storage,
        loginStore: MemoryJwxtLoginStore('https://vpn.example.edu.cn'),
        clock: fixedNow,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('preview', (WidgetTester tester) async {
    await pumpApp(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/timetable.png'),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('今日'),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/today.png'),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('设置'),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/settings.png'),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('导入'),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/import.png'),
    );
  });
}
