import 'package:equatable/equatable.dart';

abstract class WeeklyUsageEvent extends Equatable {
  const WeeklyUsageEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeeklyAnalysis extends WeeklyUsageEvent {}

class UpdateSelectedDate extends WeeklyUsageEvent {
  final DateTime selectedDate;

  const UpdateSelectedDate({required this.selectedDate});

  @override
  List<Object?> get props => [selectedDate];
}

class UpdateTotalUsage extends WeeklyUsageEvent {
  final int totalUsage;

  const UpdateTotalUsage({required this.totalUsage});

  @override
  List<Object?> get props => [totalUsage];
}
