import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit.dart';
import '../repositories/i_habit_repository.dart';

@lazySingleton
class AddHabit implements UseCase<Unit, AddHabitParams> {
  final IHabitRepository _repository;
  const AddHabit(this._repository);

  @override
  Future<Either<Failure, Unit>> call(AddHabitParams params) async {
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure('Habit name cannot be empty.'));
    }
    if (params.frequency == HabitFrequency.custom && params.weekDays.isEmpty) {
      return const Left(
          ValidationFailure('Please select at least one day.'));
    }
    return _repository.add(params.toEntity());
  }
}

class AddHabitParams extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final String? description;
  final HabitFrequency frequency;
  final List<int> weekDays;
  final DateTime startDate;
  final String colorHex;

  const AddHabitParams({
    required this.id,
    required this.name,
    required this.iconName,
    this.description,
    required this.frequency,
    required this.weekDays,
    required this.startDate,
    required this.colorHex,
  });

  Habit toEntity() => Habit(
        id: id,
        name: name,
        iconName: iconName,
        description: description,
        frequency: frequency,
        weekDays: weekDays,
        startDate: startDate,
        completedDates: const [],
        colorHex: colorHex,
      );

  @override
  List<Object?> get props =>
      [id, name, iconName, description, frequency, weekDays, startDate, colorHex];
}
