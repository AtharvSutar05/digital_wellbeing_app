import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:wellbeing_app/models/app_usage_model.dart';
import 'package:wellbeing_app/models/daily_usage_model.dart';

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

  DailyUsageModel? getUsageByDate(DateTime date) {
    final formattedDate = DateFormat("yyyy-MM-dd").format(date);
    return _dailyUsageBox.get(formattedDate);
  }
}
