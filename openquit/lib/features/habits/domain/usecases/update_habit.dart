import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit.dart';
import '../repositories/i_habit_repository.dart';

@lazySingleton
class UpdateHabit implements UseCase<Unit, Habit> {
  final IHabitRepository _repository;
  const UpdateHabit(this._repository);

  @override
  Future<Either<Failure, Unit>> call(Habit params) async {
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure('Habit name cannot be empty.'));
    }
    if (params.frequency == HabitFrequency.custom && params.weekDays.isEmpty) {
      return const Left(
          ValidationFailure('Please select at least one day.'));
    }
    return _repository.update(params);
  }
}
