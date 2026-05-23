import 'package:hive/hive.dart';

part 'app_meta_data_model.g.dart';

@HiveType(typeId: 0)
class AppMetaDataModel extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime lastSynced;

  @HiveField(3)
  final int? categoryIndex;

  @HiveField(4)
  final int? dailyLimit;

  @HiveField(5)
  final bool? isBlocked;

  @HiveField(6)
  final bool? isLaunchable;

  @HiveField(7)
  final bool? isTracked;

  AppMetaDataModel({
    required this.packageName,
    required this.name,
    required this.lastSynced,
    this.categoryIndex,
    this.dailyLimit,
    this.isBlocked,
    this.isLaunchable,
    this.isTracked,
  });
}
