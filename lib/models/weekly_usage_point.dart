class WeeklyUsagePoint {
  final DateTime date;
  final int usageMillis;

  const WeeklyUsagePoint({
    required this.date,
    required this.usageMillis,
  });

  String get dayLabel {
    const labels = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ];

    return labels[date.weekday % 7];
  }
}