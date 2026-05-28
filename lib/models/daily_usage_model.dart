import 'package:hive/hive.dart';
import 'package:wellbeing_app/models/app_usage_model.dart';

part 'daily_usage_model.g.dart';

@HiveType(typeId: 1)
class DailyUsageModel extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final int totalUsageMillis; // milliseconds

  @HiveField(2)
  final List<AppUsageModel> apps;

  DailyUsageModel({
    required this.date,
    required this.totalUsageMillis,
    required this.apps,
  });
}

