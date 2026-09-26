import 'package:flutter/material.dart';

import '../models/course_session.dart';
import '../models/semester.dart';

Future<void> showCourseDetailSheet(
  BuildContext context, {
  required CourseSession session,
  required Semester semester,
  required int week,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[],
          ),
        ),
      );
    },
  );
}
