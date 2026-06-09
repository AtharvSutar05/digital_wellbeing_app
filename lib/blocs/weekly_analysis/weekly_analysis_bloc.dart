import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/weekly_analysis/weekly_analysis_state.dart';
import 'package:wellbeing_app/blocs/weekly_analysis/weekly_usage_event.dart';
import 'package:wellbeing_app/models/app_usage_model.dart';
import 'package:wellbeing_app/models/weekly_usage_point.dart';
import 'package:wellbeing_app/services/app_usage_service.dart';
import 'package:wellbeing_app/services/daily_usage_service.dart';
import 'package:wellbeing_app/utils/extensions.dart';

class WeeklyAnalysisBloc extends Bloc<WeeklyUsageEvent, WeeklyAnalysisState> {
  final DailyUsageService _dailyUsageService = DailyUsageService();
  final AppUsageService _appUsageService = AppUsageService();
  WeeklyAnalysisBloc() : super(WeeklyAnalysisLoading()) {
    on<LoadWeeklyAnalysis>(onLoadWeeklyAnalysis);
    on<UpdateSelectedDate>(onUpdateSelectedDate);
    on<UpdateTotalUsage>(onUpdateTotalUsage);
  }

  Future<void> onLoadWeeklyAnalysis(
    LoadWeeklyAnalysis event,
    Emitter<WeeklyAnalysisState> emit,
  ) async {
    emit(WeeklyAnalysisLoading());
    try {
      final DateTime today = DateTime.now().toDateOnly();

      // 1. Calculate today's live total usage from the system stats
      final List<AppUsageModel> todayAppsUsage = await _appUsageService
          .getUsageStats();

      final todayTotalUsage = todayAppsUsage.fold<int>(
        0,
        (sum, app) => sum + app.usageMillis,
      );

      // 2. Pass that live total directly into your week generator
      List<WeeklyUsagePoint> weeklyUsage = _dailyUsageService
          .getCurrentWeekUsage(liveTodayUsage: todayTotalUsage);

      // 3. Emit everything safely
      emit(
        WeeklyAnalysisLoaded(
          weeklyUsage: weeklyUsage,
          selectedDate: today,
          totalUsage: todayTotalUsage,
        ),
      );
    } catch (e) {
      emit(WeeklyAnalysisError(message: e.toString()));
    }
  }

  void onUpdateSelectedDate(
    UpdateSelectedDate event,
    Emitter<WeeklyAnalysisState> emit,
  ) {
    final currentState = state;
    if (currentState is WeeklyAnalysisLoaded) {
      emit(currentState.copyWith(selectedDate: event.selectedDate));
    }
  }

  void onUpdateTotalUsage(
    UpdateTotalUsage event,
    Emitter<WeeklyAnalysisState> emit,
  ) {
    final currentState = state;
    if (currentState is WeeklyAnalysisLoaded) {
      emit(currentState.copyWith(totalUsage: event.totalUsage));
    }
  }
}
