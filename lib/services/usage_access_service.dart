import 'package:flutter/services.dart';

class UsageAccessService {
  static const _platform = MethodChannel('com.example.wellbeing_app/usage');

  Future<bool> isUsageAccessGranted() async {
    try {
      final result = await _platform.invokeMethod<bool>('isUsageAccessGranted');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> openUsageAccessSettings() async {
    try {
      await _platform.invokeMethod('openUsageAccessSettings');
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }
}