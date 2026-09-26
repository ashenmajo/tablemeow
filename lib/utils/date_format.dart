// 日期格式化工具：只做课表需要的少量格式化，避免引入 locale 依赖。

String twoDigits(int value) => value.toString().padLeft(2, '0');

//举例

// 08:05
String formatClock(DateTime time) =>
    '${twoDigits(time.hour)}:${twoDigits(time.minute)}';

// 9月23日
String formatMonthDay(DateTime date) => '${date.month}月${date.day}日';

// 9月23日 - 9月29日
String formatDateRange(DateTime start, DateTime end) =>
    '${formatMonthDay(start)} - ${formatMonthDay(end)}';
