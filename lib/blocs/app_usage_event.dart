import 'package:equatable/equatable.dart';

abstract class AppUsageEvent extends Equatable {
  const AppUsageEvent();
  @override
  List<Object?> get props => [];
}

class LoadAppsUsage extends AppUsageEvent {}