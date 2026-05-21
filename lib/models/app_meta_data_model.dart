import 'package:hive/hive.dart';

part 'app_meta_data_model.g.dart';

@HiveType(typeId: 0)
class AppMetaDataModel extends HiveObject {
  @HiveField(0)
  final String packageName;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int categoryIndex; // store enum as int

  @HiveField(3)
  final int? customCategoryIndex;

  @HiveField(4)
  final bool? isLaunchable;

  @HiveField(5)
  final DateTime lastSynced;

  AppMetaDataModel({
    required this.packageName,
    required this.name,
    required this.categoryIndex,
    this.customCategoryIndex,
    this.isLaunchable,
    required this.lastSynced,
  });
}