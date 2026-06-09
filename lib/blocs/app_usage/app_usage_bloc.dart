import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_event.dart';
import 'package:wellbeing_app/blocs/app_usage/app_usage_state.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';
import 'package:wellbeing_app/repositories/app_usage_repository.dart';
import 'package:wellbeing_app/services/app_meta_data_cache_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:wellbeing_app/utils/extensions.dart';

class AppUsageBloc extends Bloc<AppUsageEvent, AppUsageState> {
  final AppUsageRepository _repository;
  final AppMetaDataCacheService _appMetaDataCacheService =
      AppMetaDataCacheService();

  AppUsageBloc({required AppUsageRepository repository}) : _repository = repository, super(AppUsageLoading()) {
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

      emit(AppUsageLoading());

      final appInfoList = await _repository.getUsageForDate(event.date);

      // Calculate total usage
      final totalUsage = appInfoList.fold<int>(
          0, (sum, app) => sum + app.usage.inMilliseconds
      );

      final selectedDate = DateTime.now().toDateOnly();

      emit(
        AppUsageLoaded(
          appInfoList: appInfoList,
          selectedDate: selectedDate,
          totalUsage: totalUsage,
        ),
      );
    } catch (e) {
      emit(AppUsageError(message: e.toString()));
    } finally {
      FlutterNativeSplash.remove();
    }
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
      add(LoadAppsUsage(date: currentState.selectedDate));
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
      add(LoadAppsUsage(date: currentState.selectedDate));
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
        add(LoadAppsUsage(date: currentState.selectedDate));
        return;
      }
      emit(
        AppUsageLoaded(
          appInfoList: updatedList,
          selectedDate: currentState.selectedDate,
          totalUsage: totalUsage,
        ),
      );
    }
  }
}
