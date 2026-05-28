import 'package:equatable/equatable.dart';
import 'package:wellbeing_app/models/custom_app_info.dart';

abstract class AppUsageState extends Equatable {
  const AppUsageState();
  @override
  List<Object?> get props => [];
}

class AppUsageLoading extends AppUsageState {}

class AppUsageLoaded extends AppUsageState {
  final List<CustomAppInfo> appInfoList;
  final DateTime selectedDate;

  const AppUsageLoaded({required this.appInfoList, required this.selectedDate});

  @override
  List<Object?> get props => [appInfoList, selectedDate];
}

class AppUsageError extends AppUsageState {
  final String message;
  const AppUsageError({required this.message});

  @override
  List<Object?> get props => [message];
}
