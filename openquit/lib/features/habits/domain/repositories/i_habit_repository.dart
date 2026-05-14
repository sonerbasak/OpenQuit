import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/habit.dart';

abstract interface class IHabitRepository {
  Future<Either<Failure, List<Habit>>> getAll();
  Future<Either<Failure, Habit>> getById(String id);
  Future<Either<Failure, Unit>> add(Habit habit);
  Future<Either<Failure, Unit>> update(Habit habit);
  Future<Either<Failure, Unit>> delete(String id);

  /// Belirli bir günü tamamlandı olarak işaretle (toggle).
  Future<Either<Failure, Unit>> toggleCompletion(String id, DateTime date);
}
