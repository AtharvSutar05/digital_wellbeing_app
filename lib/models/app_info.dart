import 'dart:typed_data';
import 'package:wellbeing_app/utils/enums.dart';

class CustomAppInfo {
  final String name;
  final Uint8List? icon;
  final String packageName;
  final Duration usage;
  final AppCategory category;
  final bool? isLaunchable;

  CustomAppInfo({
    required this.name,
    required this.icon,
    required this.packageName,
    required this.usage,
    required this.category,
    required this.isLaunchable,
  });
}
