import 'package:hive/hive.dart';

part 'app_usage_model.g.dart';

@HiveType(typeId: 2)
class AppUsageModel extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final int usageMillis; // milliseconds

  AppUsageModel({
    required this.packageName,
    required this.usageMillis,
  });
}