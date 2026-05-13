import 'package:wellbeing_app/utils/enums.dart';

class CustomAppInfo {
  final String name;
  final String packageName;
  final Duration usage;
  final AppCategory category;
  final bool? isLaunchable;

  CustomAppInfo({
    required this.name,
    required this.packageName,
    required this.usage,
    required this.category,
    required this.isLaunchable,
  });
}
