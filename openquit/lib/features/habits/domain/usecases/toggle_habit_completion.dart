import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_habit_repository.dart';

@lazySingleton
class ToggleHabitCompletion
    implements UseCase<Unit, ToggleHabitCompletionParams> {
  final IHabitRepository _repository;
  const ToggleHabitCompletion(this._repository);

  @override
  Future<Either<Failure, Unit>> call(ToggleHabitCompletionParams params) =>
      _repository.toggleCompletion(params.id, params.date);
}

class ToggleHabitCompletionParams extends Equatable {
  final String id;
  final DateTime date;

  const ToggleHabitCompletionParams({required this.id, required this.date});

  @override
  List<Object?> get props => [id, date];
}
