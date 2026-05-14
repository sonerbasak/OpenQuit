part of 'habit_list_cubit.dart';

sealed class HabitListState extends Equatable {
  const HabitListState();
}

final class HabitListInitial extends HabitListState {
  const HabitListInitial();
  @override
  List<Object?> get props => [];
}

final class HabitListLoading extends HabitListState {
  const HabitListLoading();
  @override
  List<Object?> get props => [];
}

final class HabitListLoaded extends HabitListState {
  final List<Habit> habits;
  const HabitListLoaded(this.habits);
  @override
  List<Object?> get props => [habits];
}

final class HabitListError extends HabitListState {
  final String message;
  const HabitListError(this.message);
  @override
  List<Object?> get props => [message];
}
