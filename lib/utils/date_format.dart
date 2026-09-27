// 日期格式化工具：只做课表需要的少量格式化，避免引入 locale 依赖

String twoDigits(int value) => value.toString().padLeft(2, '0');

String formatClock(DateTime time) =>
    '${twoDigits(time.hour)}:${twoDigits(time.minute)}';

String formatMonthDay(DateTime date) => '${date.month}月${date.day}日';

String formatDateRange(DateTime start, DateTime end) =>
    '${formatMonthDay(start)} - ${formatMonthDay(end)}';
