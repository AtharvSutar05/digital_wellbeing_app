import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage_event.dart';
import 'package:wellbeing_app/blocs/app_usage_state.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/models/app_meta_data_model.dart';
import 'package:wellbeing_app/models/app_usage_data.dart';
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
    on<UpdateCategory>(onUpdateCategory);
    on<UpdateDailyLimit>(onUpdateDailyLimit);
  }

  Future<void> onLoadAppsUsage(
    LoadAppsUsage event,
    Emitter<AppUsageState> emit,
  ) async {
    try {
      emit(AppUsageLoading());

      //fetching usage state and local storage
      final results = await Future.wait([
        _appUsageService.getUsageStats(),
        _appMetaDataCacheService.loadAll(),
      ]);

      final appsUsage = results[0] as List<AppUsageData>;
      Map<String, AppMetaDataModel>? appInfoMap =
          results[1] as Map<String, AppMetaDataModel>?;

      // empty local storage
      if (appInfoMap == null) {
        final packageNames = appsUsage.map((e) => e.packageName).toList();
        final appInfoList = await _appInfoService.getAppInfoList(packageNames);
        await _appMetaDataCacheService.saveAll(appInfoList);
        appInfoMap = await _appMetaDataCacheService.loadAll() ?? {};
      }

      final missingPackageNames = appsUsage
          .where((usage) => !appInfoMap!.containsKey(usage.packageName))
          .map((usage) => usage.packageName)
          .toList();

      if (missingPackageNames.isNotEmpty) {
        final missingAppInfoList = await _appInfoService.getAppInfoList(
          missingPackageNames,
        );
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
          appInfoList: makeCustomAppInfoList(appsUsage, appInfoMap),
        ),
      );
    } catch (e) {
      emit(AppUsageError(message: e.toString()));
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  List<CustomAppInfo> makeCustomAppInfoList(
    List<AppUsageData> appsUsage,
    Map<String, AppMetaDataModel> appInfoMap,
  ) {
    final customAppInfoList =
        appsUsage
            .where((usage) {
              final app = appInfoMap[usage.packageName];
              return usage.usage.inSeconds > 0 &&
                  app?.isLaunchable == true &&
                  !ignoredPackages.contains(usage.packageName);
            })
            .map((usage) {
              final app = appInfoMap[usage.packageName];
              return CustomAppInfo(
                packageName: usage.packageName,
                name: app?.name ?? usage.packageName,
                usage: usage.usage,
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

    return customAppInfoList;
  }

  Future<void> onUpdateCategory(
    UpdateCategory event,
    Emitter<AppUsageState> emit,
  ) async {
    await _appMetaDataCacheService.updateCategory(
      packageName: event.packageName,
      categoryIndex: event.category.index,
    );
    add(LoadAppsUsage());
  }

  Future<void> onUpdateDailyLimit(
    UpdateDailyLimit event,
    Emitter<AppUsageState> emit,
  ) async {
    await _appMetaDataCacheService.updateDailyLimit(
      packageName: event.packageName,
      dailyLimit: event.dailyLimit,
    );
    add(LoadAppsUsage());
  }
}
