import 'package:app_usage/app_usage.dart';

class AppUsageService {
  Future<List<AppUsageInfo>> getUsageStats() async {
    try {
      final now = DateTime.now();

      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = now;

      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(
        startOfDay,
        endOfDay,
      );
      return infoList;
    } catch (e) {
      rethrow;
    }
  }
}
