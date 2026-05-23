import 'package:wellbeing_app/utils/enums.dart';

class CustomAppInfo {
  final String name;
  final String packageName;
  final Duration usage;
  final AppCategory? category;
  final int? dailyLimit;
  final bool? isBlocked;
  final bool? isLaunchable;
  final bool? isTracked;

  CustomAppInfo({
    required this.name,
    required this.packageName,
    required this.usage,
    this.category,
    this.dailyLimit,
    this.isBlocked,
    this.isLaunchable,
    this.isTracked,
  });
}
