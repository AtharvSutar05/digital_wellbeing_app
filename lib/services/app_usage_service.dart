import 'package:flutter/services.dart';
import 'package:wellbeing_app/models/app_usage_model.dart';

class AppUsageService {
  static const platform = MethodChannel('com.example.wellbeing_app/usage');
  Future<List<AppUsageModel>> getUsageStats() async {
    try {
      final now = DateTime.now();

      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = now;

      // 1. Get the raw Map from Kotlin
      final Map<dynamic, dynamic>? nativeData = await platform
          .invokeMethod('getPreciseUsage', {
            'start': startOfDay.millisecondsSinceEpoch,
            'end': endOfDay.millisecondsSinceEpoch,
          });

      if (nativeData == null) return [];

      // 2. Convert Map<String, int> into List<AppUsageInfo>
      List<AppUsageModel> infoList = [];

      nativeData.forEach((packageName, durationInMs) {
        infoList.add(
          AppUsageModel(
            packageName: packageName.toString(),
            usageMillis: durationInMs,
          ),
        );
      });

      return infoList;
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }
}
