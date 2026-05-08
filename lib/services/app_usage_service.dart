import 'package:app_usage/app_usage.dart';
import 'package:flutter/services.dart';

class AppUsageService {

  static const platform = MethodChannel('com.example.wellbeing_app/usage');
  Future<List<AppUsageInfo>> getUsageStats() async {
    try {
      final now = DateTime.now();

      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = now;

      // 1. Get the raw Map from Kotlin
      final Map<dynamic, dynamic>? nativeData = await platform.invokeMethod('getPreciseUsage', {
        'start': startOfDay.millisecondsSinceEpoch,
        'end': now.millisecondsSinceEpoch,
      });

      if (nativeData == null) return [];

      // 2. Convert Map<String, int> into List<AppUsageInfo>
      List<AppUsageInfo> infoList = [];

      nativeData.forEach((packageName, durationInMs) {
        // AppUsageInfo expects (packageName, usage_in_seconds, start_time, end_time)
        // We calculate seconds from the milliseconds returned by Kotlin
        double usageInSeconds = durationInMs / 1000.0;

        infoList.add(AppUsageInfo(
          packageName.toString(),
          usageInSeconds,
          startOfDay, // The start of your query
          endOfDay, // The end of your query
          now
        ));
      });

      return infoList;
    } on PlatformException catch (e) {
      print("Failed to get native usage: ${e.message}");
      rethrow;
    }
  }
}
