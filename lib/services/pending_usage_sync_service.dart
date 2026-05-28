import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:wellbeing_app/services/daily_usage_service.dart';

class PendingUsageSyncService {
  static final PendingUsageSyncService _instance =
      PendingUsageSyncService._internal();

  factory PendingUsageSyncService() => _instance;

  PendingUsageSyncService._internal();

  static final _platform = MethodChannel('com.example.wellbeing_app/usage');
  final DailyUsageService _dailyUsageService = DailyUsageService();

  Future<void> syncPendingUsage() async {
    final json = await _platform.invokeMethod<String>("getPendingUsageSync");
    if (json == null) {
      return;
    }
    final decodedYesterdayUsage = Map<String, dynamic>.from(jsonDecode(json));

    final usageMap = decodedYesterdayUsage.map(
      (key, value) => MapEntry(key, value as int),
    );

    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    await _dailyUsageService.saveDailyUsage(
      date: yesterday,
      appsUsage: usageMap,
    );

    await _platform.invokeMethod('clearPendingUsageSync');
  }
}
