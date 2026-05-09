class AppUsageData {
  final String packageName;
  final Duration usage;
  final DateTime start;
  final DateTime end;
  final DateTime lastForeground;

  AppUsageData( {
    required this.packageName,
    required this.usage,
    required this.start,
    required this.end,
    required this.lastForeground,
  });
}
