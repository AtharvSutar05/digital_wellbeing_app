import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_event.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_state.dart';
import 'package:wellbeing_app/models/app_usage_model.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/models/app_meta_data_model.dart';
import 'package:wellbeing_app/models/weekly_usage_point.dart';
import 'package:wellbeing_app/services/app_info_service.dart';
import 'package:wellbeing_app/services/app_meta_data_cache_service.dart';
import 'package:wellbeing_app/services/app_usage_service.dart';
import 'package:wellbeing_app/services/daily_usage_service.dart';
import 'package:wellbeing_app/utils/enums.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AppUsageBloc extends Bloc<AppUsageEvent, AppUsageState> {
  final AppUsageService _appUsageService = AppUsageService();
  final AppInfoService _appInfoService = AppInfoService();
  final DailyUsageService _dailyUsageService = DailyUsageService();
  final AppMetaDataCacheService _appMetaDataCacheService =
      AppMetaDataCacheService();

  AppUsageBloc() : super(AppUsageLoading()) {
    on<LoadAppsUsage>(onLoadAppsUsage);
    on<UpdateCategory>(onUpdateCategory);
    on<UpdateDailyLimit>(onUpdateDailyLimit);
    on<UpdateTracking>(onUpdateTracking);
  }

  Future<void> onLoadAppsUsage(
    LoadAppsUsage event,
    Emitter<AppUsageState> emit,
  ) async {
    try {
      // Keep track of what the state was before we emit loading
      final currentState = state;

      emit(AppUsageLoading());
      List<AppUsageModel> appsUsage;

      final selectedDate = DateTime(event.date.year, event.date.month, event.date.day);

      final isToday =
          selectedDate.year == DateTime.now().year &&
          selectedDate.month == DateTime.now().month &&
          selectedDate.day == DateTime.now().day;

      if (isToday) {
        appsUsage = await _appUsageService.getUsageStats();
      } else {
        final dailyUsage = _dailyUsageService.getUsageByDate(selectedDate);
        appsUsage = dailyUsage?.apps ?? [];
      }

      Map<String, AppMetaDataModel>? appInfoMap = await _appMetaDataCacheService
          .loadAll();

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

      final appInfoList = makeCustomAppInfoList(appsUsage, appInfoMap);
      int totalUsage = 0;
      for (final app in appInfoList) {
        totalUsage += app.usage.inMilliseconds;
      }

      int trackedTodayUsage = 0;

      if (isToday) {
        // If we are looking at today, this fresh calculation IS today's usage
        trackedTodayUsage = totalUsage;
      } else if (currentState is AppUsageLoaded) {
        // If we are looking at history, pull today's usage from our previous state memory
        trackedTodayUsage = currentState.todayTotalUsage;
      } else {
        // Fallback: If there's no state history yet, try to read the live stats right now
        // or fall back to 0 if that fails
        final liveStats = await _appUsageService.getUsageStats();
        trackedTodayUsage = liveStats.fold(0, (sum, item) => sum + item.usageMillis);
      }

      // Always pass the tracked today usage to keep the graph stable!
      List<WeeklyUsagePoint> weeklyUsage = _dailyUsageService.getCurrentWeekUsage(
        liveTodayUsage: trackedTodayUsage,
      );

      emit(
        AppUsageLoaded(
          appInfoList: appInfoList,
          weeklyUsage: weeklyUsage,
          selectedDate: selectedDate,
          totalUsage: totalUsage,
          todayTotalUsage: trackedTodayUsage,
        ),
      );
    } catch (e) {
      emit(AppUsageError(message: e.toString()));
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  List<CustomAppInfo> makeCustomAppInfoList(
    List<AppUsageModel> appsUsage,
    Map<String, AppMetaDataModel> appInfoMap,
  ) {
    final customAppInfoList =
        appsUsage
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
    final currentState = state;
    if (currentState is AppUsageLoaded) {
      add(
        LoadAppsUsage(
          date: currentState.selectedDate,
          totalUsage: currentState.totalUsage,
        ),
      );
    }
  }

  Future<void> onUpdateDailyLimit(
    UpdateDailyLimit event,
    Emitter<AppUsageState> emit,
  ) async {
    await _appMetaDataCacheService.updateDailyLimit(
      packageName: event.packageName,
      dailyLimit: event.dailyLimit,
    );
    final currentState = state;
    if (currentState is AppUsageLoaded) {
      add(
        LoadAppsUsage(
          date: currentState.selectedDate,
          totalUsage: currentState.totalUsage,
        ),
      );
    }
  }

  Future<void> onUpdateTracking(
    UpdateTracking event,
    Emitter<AppUsageState> emit,
  ) async {
    await _appMetaDataCacheService.updateTracking(
      packageName: event.packageName,
      isTracking: event.isTracking,
    );
    final currentState = state;
    if (currentState is AppUsageLoaded) {
      final updatedList = List<CustomAppInfo>.from(currentState.appInfoList);
      int totalUsage = currentState.totalUsage;
      if (!event.isTracking) {
        final removedApp = updatedList.firstWhere(
          (app) => app.packageName == event.packageName,
        );

        totalUsage -= removedApp.usage.inMilliseconds;

        updatedList.removeWhere((app) => app.packageName == event.packageName);
      } else {
        add(
          LoadAppsUsage(
            date: currentState.selectedDate,
            totalUsage: totalUsage,
          ),
        );
        return;
      }
      emit(
        AppUsageLoaded(
          appInfoList: updatedList,
          weeklyUsage: currentState.weeklyUsage,
          selectedDate: currentState.selectedDate,
          totalUsage: totalUsage,
          todayTotalUsage: currentState.todayTotalUsage
        ),
      );
    }
  }
}
