import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_event.dart';
import 'package:wellbeing_app/blocs/app_usage_state.dart';
import 'package:wellbeing_app/models/app_info.dart';
import 'package:wellbeing_app/models/app_meta_data_model.dart';
import 'package:wellbeing_app/models/app_usage_data.dart';
import 'package:wellbeing_app/models/category_group.dart';
import 'package:wellbeing_app/services/app_info_service.dart';
import 'package:wellbeing_app/services/app_meta_data_cache_service.dart';
import 'package:wellbeing_app/services/app_usage_service.dart';
import 'package:wellbeing_app/utils/enums.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AppUsageBloc extends Bloc<AppUsageEvent, AppUsageState> {
  final AppUsageService _appUsageService = AppUsageService();
  final AppInfoService _appInfoService = AppInfoService();
  final AppMetaDataCacheService _appMetaDataCacheService =
      AppMetaDataCacheService();
  final ignoredPackages = {
    'com.android.systemui',
    'com.miui.home',
    'com.google.android.inputmethod.latin',
  };

  AppUsageBloc() : super(AppUsageLoading()) {
    on<LoadAppsUsage>(onLoadAppsUsage);
  }

  Future<void> onLoadAppsUsage(
    LoadAppsUsage event,
    Emitter<AppUsageState> emit,
  ) async {
    try {
      emit(AppUsageLoading());

      // Run usage stats and cache load in parallel
      final results = await Future.wait([
        _appUsageService.getUsageStats(),
        _appMetaDataCacheService.loadAll(),
      ]);

      final appsUsage = results[0] as List<AppUsageData>;
      Map<String, AppMetaDataModel>? appInfoMap =
          results[1] as Map<String, AppMetaDataModel>?;

      // Slow path — only on first launch or stale cache
      if (appInfoMap == null) {
        final installedApps = await _appInfoService.getInstalledApps();
        await _appMetaDataCacheService.saveAll(installedApps);
        appInfoMap = await _appMetaDataCacheService.loadAll() ?? {};
      }

      final missingPackages = appsUsage
          .where((usage) => !appInfoMap!.containsKey(usage.packageName))
          .map((usage) => usage.packageName)
          .toList();

      if(missingPackages.isNotEmpty) {
        final missingAppInfoList = await _appInfoService.getMissingAppInfoList(missingPackages);
        await _appMetaDataCacheService.saveAll(missingAppInfoList);
        final now = DateTime.now();
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

      appInfoMap.remove("com.example.wellbeing_app");
      emit(
        AppUsageLoaded(
          categoryGroupList: _buildCategoryGroups(appsUsage, appInfoMap),
        ),
      );
    } catch (e) {
      emit(AppUsageError(message: e.toString()));
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  // 👇 extracted — single source of truth
  List<CategoryGroup> _buildCategoryGroups(
    List<AppUsageData> appsUsage,
    Map<String, AppMetaDataModel> appInfoMap,
  ) {
    final mergedList = appsUsage
        .where((usage) {
          final app = appInfoMap[usage.packageName];
          return usage.usage.inSeconds > 0 &&
              app?.isLaunchable == true &&
              !ignoredPackages.contains(usage.packageName);
        })
        .map((usage) {
          final app = appInfoMap[usage.packageName];
          return CustomAppInfo(
            name: app?.name ?? usage.packageName,
            packageName: usage.packageName,
            usage: usage.usage,
            category: appCategoryConverter(
              categoryInt: app?.categoryIndex,
              packageName: usage.packageName,
            ),
            isLaunchable: app?.isLaunchable,
          );
        })
        .toList();

    final grouped = <AppCategory, List<CustomAppInfo>>{};
    for (final app in mergedList) {
      grouped.putIfAbsent(app.category, () => []).add(app);
    }

    return grouped.entries
        .map(
          (entry) => CategoryGroup(
            category: entry.key,
            apps: [...entry.value]..sort((a, b) => b.usage.compareTo(a.usage)),
            totalUsage: entry.value.fold(
              Duration.zero,
              (sum, app) => sum + app.usage,
            ),
          ),
        )
        .toList()
      ..sort((a, b) => b.totalUsage.compareTo(a.totalUsage));
  }
}
