import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wellbeing_app/blocs/analytics/analytics_event.dart';
import 'package:wellbeing_app/blocs/analytics/analytics_state.dart';
import 'package:wellbeing_app/services/daily_usage_service.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final DailyUsageService _dailyUsageService = DailyUsageService();
  AnalyticsBloc() : super(AnalyticsLoading()) {
    on<LoadWeeklyAnalytics>(onLoadWeeklyAnalytics);
    on<UpdateAnalyticsDateAndUsage>(onSelectAnalyticsDate);
  }

  Future<void> onLoadWeeklyAnalytics(
    LoadWeeklyAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    final weeklyUsage = _dailyUsageService.getCurrentWeekUsage();
    emit(
      AnalyticsLoaded(
        weeklyUsage: weeklyUsage,
        selectedDate: DateTime.now(),
      ),
    );
  }

  void onSelectAnalyticsDate(
    UpdateAnalyticsDateAndUsage event,
    Emitter<AnalyticsState> emit,
  ) {
    if (state is AnalyticsLoaded) {
      emit(
        (state as AnalyticsLoaded).copyWith(
          selectedDate: event.date,
        ),
      );
    }
  }
}
