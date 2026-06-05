import 'package:equatable/equatable.dart';
import 'package:wellbeing_app/models/weekly_usage_point.dart';

abstract class WeeklyAnalysisState extends Equatable {
  const WeeklyAnalysisState();

  @override
  List<Object?> get props => [];
}

class WeeklyAnalysisLoading extends WeeklyAnalysisState {}

class WeeklyAnalysisLoaded extends WeeklyAnalysisState {
  final List<WeeklyUsagePoint> weeklyUsage;
  final DateTime selectedDate; // default today
  final int totalUsage; // default today's total usage

  const WeeklyAnalysisLoaded({
    required this.weeklyUsage,
    required this.selectedDate,
    required this.totalUsage,
  });

  WeeklyAnalysisLoaded copyWith({DateTime? selectedDate, int? totalUsage}) {
    return WeeklyAnalysisLoaded(
      weeklyUsage: weeklyUsage,
      selectedDate: selectedDate ?? this.selectedDate,
      totalUsage: totalUsage ?? this.totalUsage,
    );
  }

  @override
  List<Object?> get props => [weeklyUsage, selectedDate, totalUsage];
}

class WeeklyAnalysisError extends WeeklyAnalysisState {
  final String message;
  const WeeklyAnalysisError({required this.message});

  @override
  List<Object?> get props => [message];
}
