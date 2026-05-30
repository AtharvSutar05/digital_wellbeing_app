import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeeklyAnalytics extends AnalyticsEvent {}

class UpdateAnalyticsDateAndUsage extends AnalyticsEvent {
  final DateTime date;

  const UpdateAnalyticsDateAndUsage({
    required this.date,
  });

  @override
  List<Object?> get props => [date];
}
