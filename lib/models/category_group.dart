import 'package:wellbeing_app/models/app_info.dart';
import 'package:wellbeing_app/utils/enums.dart';

class CategoryGroup {
  final AppCategory category;
  final List<CustomAppInfo> apps;
  final Duration totalUsage;

  const CategoryGroup({
    required this.category,
    required this.apps,
    required this.totalUsage,
  });
}