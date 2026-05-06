import 'package:equatable/equatable.dart';
import 'package:wellbeing_app/models/category_group.dart';

abstract class AppUsageState extends Equatable {
  const AppUsageState();
  @override
  List<Object?> get props => [];
}

class AppUsageInitial extends AppUsageState {}

class AppUsageLoading extends AppUsageState {}

class AppUsageLoaded extends AppUsageState {
  final List<CategoryGroup> categoryGroupList;

  const AppUsageLoaded({required this.categoryGroupList});

  @override
  List<Object?> get props => [categoryGroupList];
}

class AppUsageError extends AppUsageState {
  final String message;
  const AppUsageError({required this.message});

  @override
  List<Object?> get props => [message];
}
