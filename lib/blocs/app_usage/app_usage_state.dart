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
  final int totalUsage;

  const AppUsageLoaded({
    required this.appInfoList,
    required this.selectedDate,
    required this.totalUsage,
  });

  AppUsageLoaded copyWith({
    List<CustomAppInfo>? appInfoList,
    DateTime? selectedDate,
    int? totalUsage,
  }) {
    return AppUsageLoaded(
      appInfoList: appInfoList ?? this.appInfoList,
      selectedDate: selectedDate ?? this.selectedDate,
      totalUsage: totalUsage ?? this.totalUsage,
    );
  }

  @override
  List<Object?> get props => [
    appInfoList,
    selectedDate,
    totalUsage
  ];
}

class AppUsageError extends AppUsageState {
  final String message;
  const AppUsageError({required this.message});

  @override
  List<Object?> get props => [message];
}
