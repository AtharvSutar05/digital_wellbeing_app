import 'package:app_usage/app_usage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:installed_apps/app_info.dart';
import 'package:wellbeing_app/blocs/app_usage_event.dart';
import 'package:wellbeing_app/blocs/app_usage_state.dart';
import 'package:wellbeing_app/models/app_info.dart';
import 'package:wellbeing_app/models/category_group.dart';
import 'package:wellbeing_app/services/app_info_service.dart';
import 'package:wellbeing_app/services/app_usage_service.dart';
import 'package:wellbeing_app/utils/enums.dart';

class AppUsageBloc extends Bloc<AppUsageEvent, AppUsageState> {
  final AppUsageService _appUsageService = AppUsageService();
  final AppInfoService _appInfoService = AppInfoService();
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
      final appsUsage = result[0] as List<AppUsageInfo>;
      final installedApps = result[1] as List<AppInfo>;

      final appInfoMap = <String, AppInfo>{
        for (final app in installedApps) app.packageName: app,
      };

      final mergedList = appsUsage
          .where((usage) {
            final installedApp = appInfoMap[usage.packageName];

            return usage.usage.inSeconds > 0 &&
                installedApp?.isLaunchableApp == true;
          })
          .map((usage) {
            final installedApp = appInfoMap[usage.packageName];
            return CustomAppInfo(
              name: installedApp?.name ?? usage.appName,
              icon: installedApp?.icon,
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

      emit(AppUsageLoaded(categoryGroupList: categoryGroups));
    } catch (e) {
      emit(AppUsageError(message: e.toString()));
    }
  }
}
