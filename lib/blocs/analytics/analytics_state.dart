import 'package:equatable/equatable.dart';
import 'package:wellbeing_app/models/weekly_usage_point.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

final class AnalyticsLoading extends AnalyticsState {}

final class AnalyticsLoaded extends AnalyticsState {
  final List<WeeklyUsagePoint> weeklyUsage;
  final DateTime selectedDate;

  const AnalyticsLoaded({
    required this.weeklyUsage,
    required this.selectedDate,
  });

  AnalyticsLoaded copyWith({
    List<WeeklyUsagePoint>? weeklyUsage,
    DateTime? selectedDate,
    int? totalUsageMillis,
  }) {
    return AnalyticsLoaded(
      weeklyUsage: weeklyUsage ?? this.weeklyUsage,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [weeklyUsage, selectedDate];
}
