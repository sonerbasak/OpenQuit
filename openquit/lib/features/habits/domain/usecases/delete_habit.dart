import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_habit_repository.dart';

@lazySingleton
class DeleteHabit implements UseCase<Unit, String> {
  final IHabitRepository _repository;
  const DeleteHabit(this._repository);

  @override
  Future<Either<Failure, Unit>> call(String id) => _repository.delete(id);
}
