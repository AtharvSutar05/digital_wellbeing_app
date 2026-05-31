import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_app/models/app_usage_model.dart';
import 'package:wellbeing_app/models/daily_usage_model.dart';
import 'package:wellbeing_app/models/weekly_usage_point.dart';

class DailyUsageService {
  static final DailyUsageService _instance = DailyUsageService._internal();

  factory DailyUsageService() => _instance;

  DailyUsageService._internal();

  static const _dailyUsageBoxName = 'daily_usage';

  late final Box<DailyUsageModel> _dailyUsageBox;

  Future<void> init() async {
    _dailyUsageBox = await Hive.openBox<DailyUsageModel>(_dailyUsageBoxName);
  }

  Future<DailyUsageModel> saveDailyUsage({
    required DateTime date,
    required Map<String, int> appsUsage,
  }) async {
    final formattedDate = DateFormat("yyyy-MM-dd").format(date);
    List<AppUsageModel> apps = [];
    int totalUsageMillis = 0;

    appsUsage.forEach((packageName, usageMillis) {
      totalUsageMillis += usageMillis;
      apps.add(
        AppUsageModel(packageName: packageName, usageMillis: usageMillis),
      );
    });

    final dailyUsage = DailyUsageModel(
      date: formattedDate,
      totalUsageMillis: totalUsageMillis,
      apps: apps,
    );

    await _dailyUsageBox.put(formattedDate, dailyUsage);

    return dailyUsage;
  }

  List<DailyUsageModel> getAllUsage() {
    return _dailyUsageBox.values.toList();
  }

  List<WeeklyUsagePoint> getCurrentWeekUsage({
    required int todayTotalUsage,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysSinceSunday = now.weekday % 7;
    final startOfWeek = today.subtract(Duration(days: daysSinceSunday));
    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year &&
          a.month == b.month &&
          a.day == b.day;
    }

    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));

      // Today's bar should use live usage
      if (isSameDay(day, today)) {
        return WeeklyUsagePoint(
          date: day,
          usageMillis: todayTotalUsage,
        );
      }

      final formattedDate = DateFormat("yyyy-MM-dd").format(day);

      final record = day.isAfter(today)
          ? null
          : _dailyUsageBox.get(formattedDate);

      return WeeklyUsagePoint(
        date: day,
        usageMillis: record?.totalUsageMillis ?? 0,
      );
    });
  }

  DailyUsageModel? getUsageByDate(DateTime date) {
    final formattedDate = DateFormat("yyyy-MM-dd").format(date);
    return _dailyUsageBox.get(formattedDate);
  }
}
