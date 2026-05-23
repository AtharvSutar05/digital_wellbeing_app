import 'package:equatable/equatable.dart';
import 'package:installed_apps/app_category.dart';

abstract class AppUsageEvent extends Equatable {
  const AppUsageEvent();
  @override
  List<Object?> get props => [];
}

class LoadAppsUsage extends AppUsageEvent {}

class UpdateCategory extends AppUsageEvent {
  final String packageName;
  final AppCategory category;

  const UpdateCategory({required this.packageName, required this.category});

  @override
  List<Object?> get props => [packageName, category];
}

class UpdateDailyLimit extends AppUsageEvent {
  final String packageName;
  final int? dailyLimit;

  const UpdateDailyLimit({required this.packageName, required this.dailyLimit});

  @override
  List<Object?> get props => [packageName, dailyLimit];
}

class UpdateTracking extends AppUsageEvent {
  final String packageName;
  final bool isTracking;

  const UpdateTracking({required this.packageName, required this.isTracking});

  @override
  List<Object?> get props => [packageName, isTracking];
}
