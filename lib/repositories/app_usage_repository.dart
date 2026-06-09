import 'package:wellbeing_app/models/app_meta_data_model.dart';
import 'package:wellbeing_app/models/app_usage_model.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/services/app_info_service.dart';
import 'package:wellbeing_app/services/app_meta_data_cache_service.dart';
import 'package:wellbeing_app/services/app_usage_service.dart';
import 'package:wellbeing_app/services/daily_usage_service.dart';
import 'package:wellbeing_app/utils/enums.dart';

abstract class AppUsageRepository {
  Future<List<CustomAppInfo>> getUsageForDate(DateTime date);
}

class AppUsageRepositoryImpl implements AppUsageRepository {
  final AppUsageService _appUsageService;
  final AppInfoService _appInfoService;
  final DailyUsageService _dailyUsageService;
  final AppMetaDataCacheService _appMetaDataCacheService;

  AppUsageRepositoryImpl({
    AppUsageService? appUsageService,
    AppInfoService? appInfoService,
    DailyUsageService? dailyUsageService,
    AppMetaDataCacheService? appMetaDataCacheService,
  })  : _appUsageService = appUsageService ?? AppUsageService(),
        _appInfoService = appInfoService ?? AppInfoService(),
        _dailyUsageService = dailyUsageService ?? DailyUsageService(),
        _appMetaDataCacheService = appMetaDataCacheService ?? AppMetaDataCacheService();

  @override
  Future<List<CustomAppInfo>> getUsageForDate(DateTime date) async {
    final selectedDate = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();

    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    List<AppUsageModel> appsUsage;
    if (isToday) {
      appsUsage = await _appUsageService.getUsageStats();
    } else {
      final dailyUsage = _dailyUsageService.getUsageByDate(selectedDate);
      appsUsage = dailyUsage?.apps ?? [];
    }

    Map<String, AppMetaDataModel>? appInfoMap = await _appMetaDataCacheService.loadAll();

    // Empty local storage fallback
    if (appInfoMap == null) {
      final packageNames = appsUsage.map((e) => e.packageName).toList();
      final appInfoList = await _appInfoService.getAppInfoList(packageNames);
      await _appMetaDataCacheService.saveAll(appInfoList);
      appInfoMap = await _appMetaDataCacheService.loadAll() ?? {};
    }

    // Check for missing metadata
    final missingPackageNames = appsUsage
        .where((usage) => !appInfoMap!.containsKey(usage.packageName))
        .map((usage) => usage.packageName)
        .toList();

    if (missingPackageNames.isNotEmpty) {
      final missingAppInfoList = await _appInfoService.getAppInfoList(missingPackageNames);
      await _appMetaDataCacheService.saveAll(missingAppInfoList);

      final missingAppMap = {
        for (final app in missingAppInfoList)
          app.packageName: AppMetaDataModel(
            packageName: app.packageName,
            name: app.name,
            categoryIndex: app.category.value,
            isLaunchable: app.isLaunchableApp,
            lastSynced: now,
          ),
      };
      appInfoMap.addAll(missingAppMap);
    }

    return _makeCustomAppInfoList(appsUsage, appInfoMap);
  }

  List<CustomAppInfo> _makeCustomAppInfoList(
      List<AppUsageModel> appsUsage,
      Map<String, AppMetaDataModel> appInfoMap,
      ) {
    return appsUsage
        .where((usage) {
      final app = appInfoMap[usage.packageName];
      return Duration(milliseconds: usage.usageMillis).inSeconds > 0 &&
          app?.isLaunchable == true &&
          app?.isTracked != false;
    })
        .map((usage) {
      final app = appInfoMap[usage.packageName];
      return CustomAppInfo(
        packageName: usage.packageName,
        name: app?.name ?? usage.packageName,
        usage: Duration(milliseconds: usage.usageMillis),
        category: appCategoryConverter(
          categoryInt: app?.categoryIndex,
          packageName: usage.packageName,
        ),
        dailyLimit: app?.dailyLimit,
        isBlocked: app?.isBlocked,
        isLaunchable: app?.isLaunchable,
      );
    })
        .toList()
      ..sort((a, b) => b.usage.compareTo(a.usage));
  }

}