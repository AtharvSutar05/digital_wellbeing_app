import 'package:flutter/services.dart';
import 'package:wellbeing_app/models/app_usage_data.dart';

class AppUsageService {
  static const platform = MethodChannel('com.example.wellbeing_app/usage');
  Future<List<AppUsageData>> getUsageStats() async {
    try {
      final now = DateTime.now();

      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = now;

      // 1. Get the raw Map from Kotlin
      final Map<dynamic, dynamic>? nativeData = await platform
          .invokeMethod('getPreciseUsage', {
            'start': startOfDay.millisecondsSinceEpoch,
            'end': now.millisecondsSinceEpoch,
          });

      if (nativeData == null) return [];

      // 2. Convert Map<String, int> into List<AppUsageInfo>
      List<AppUsageData> infoList = [];

      nativeData.forEach((packageName, durationInMs) {
        Duration usage = Duration(milliseconds: durationInMs);
        infoList.add(
          AppUsageData(
            packageName: packageName.toString(),
            usage: usage,
            start: startOfDay,
            end: endOfDay,
            lastForeground: now,
          ),
        );
      });

      return infoList;
    } on PlatformException catch (e) {
      print("Failed to get native usage: ${e.message}");
      rethrow;
    }
  }
}
