import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_app/models/app_usage_model.dart';
import 'package:wellbeing_app/models/daily_usage_model.dart';
import 'package:wellbeing_app/models/weekly_usage_point.dart';
import 'package:wellbeing_app/utils/extensions.dart';

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


  List<WeeklyUsagePoint> getCurrentWeekUsage({int? liveTodayUsage}) {
    final today = DateTime.now().toDateOnly();
    final daysSinceSunday = today.weekday % 7;
    final startOfWeek = today.subtract(Duration(days: daysSinceSunday));

    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      final formattedDate = DateFormat("yyyy-MM-dd").format(day);

      // If it's today, prioritize live statistics over old disk data
      if (day.isAtSameMomentAs(today)) {
        if (liveTodayUsage != null) {
          return WeeklyUsagePoint(date: day, usageMillis: liveTodayUsage);
        }
        final todayRecord = _dailyUsageBox.get(formattedDate);
        return WeeklyUsagePoint(date: day, usageMillis: todayRecord?.totalUsageMillis ?? 0);
      }

      // Future days return 0, past days read from Hive
      final record = day.isAfter(today) ? null : _dailyUsageBox.get(formattedDate);
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
