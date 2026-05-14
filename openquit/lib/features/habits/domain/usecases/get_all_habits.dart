import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/habit.dart';
import '../repositories/i_habit_repository.dart';

@lazySingleton
class GetAllHabits implements UseCase<List<Habit>, NoParams> {
  final IHabitRepository _repository;
  const GetAllHabits(this._repository);

  @override
  Future<Either<Failure, List<Habit>>> call(NoParams params) =>
      _repository.getAll();
}
