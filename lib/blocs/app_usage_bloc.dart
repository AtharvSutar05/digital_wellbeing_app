import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:wellbeing_app/blocs/app_usage_event.dart';
import 'package:wellbeing_app/blocs/app_usage_state.dart';
import 'package:wellbeing_app/models/app_info.dart';
import 'package:wellbeing_app/models/app_usage_data.dart';
import 'package:wellbeing_app/models/category_group.dart';
import 'package:wellbeing_app/services/app_info_service.dart';
import 'package:wellbeing_app/services/app_usage_service.dart';
import 'package:wellbeing_app/utils/enums.dart';

class AppUsageBloc extends Bloc<AppUsageEvent, AppUsageState> {
  final AppUsageService _appUsageService = AppUsageService();
  final AppInfoService _appInfoService = AppInfoService();
  final ignoredPackages = {
    'com.android.systemui',
    'com.miui.home',
    'com.google.android.inputmethod.latin',
    'com.android.settings',
  };
  AppUsageBloc() : super(AppUsageInitial()) {
    on<LoadAppsUsage>(onLoadAppsUsage);
  }
  Future<void> onLoadAppsUsage(
    LoadAppsUsage event,
    Emitter<AppUsageState> emit,
  ) async {
    try {
      emit(AppUsageLoading());
      final result = await Future.wait([
        _appUsageService.getUsageStats(),
        _appInfoService.getInstalledApps(),
      ]);
      final appsUsage = result[0] as List<AppUsageData>;
      final installedApps = result[1] as List<AppInfo>;

      final appInfoMap = <String, AppInfo>{
        for (final app in installedApps) app.packageName: app,
      };

      // don't forgot to remove wellbeing application
      appInfoMap.remove("com.example.wellbeing_app");

      final mergedList = appsUsage
          .where((usage) {
            final installedApp = appInfoMap[usage.packageName];

            return usage.usage.inSeconds > 0 &&
                installedApp?.isLaunchableApp == true &&
                !ignoredPackages.contains(usage.packageName);
          })
          .map((usage) {
            final installedApp = appInfoMap[usage.packageName];
            return CustomAppInfo(
              name: installedApp?.name ?? usage.packageName,
              packageName: usage.packageName,
              usage: usage.usage,
              category: appCategoryConverter(
                categoryInt: installedApp?.category.value,
                packageName: usage.packageName,
              ),
              isLaunchable: installedApp?.isLaunchableApp,
            );
          })
          .toList();

      final grouped = <AppCategory, List<CustomAppInfo>>{};
      for (final app in mergedList) {
        grouped.putIfAbsent(app.category, () => []).add(app);
      }
      final categoryGroups =
          grouped.entries
              .map(
                (entry) => CategoryGroup(
                  category: entry.key,
                  apps: [...entry.value]
                    ..sort((a, b) => b.usage.compareTo(a.usage)),
                  totalUsage: entry.value.fold(
                    Duration.zero,
                    (sum, app) => sum + app.usage,
                  ),
                ),
              )
              .toList()
            ..sort((a, b) => b.totalUsage.compareTo(a.totalUsage));
      debugPrint(categoryGroups[0].apps[0].packageName);

      emit(AppUsageLoaded(categoryGroupList: categoryGroups));
    } catch (e) {
      emit(AppUsageError(message: e.toString()));
    }
  }
}


