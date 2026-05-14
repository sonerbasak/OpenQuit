import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/i_habit_repository.dart';
import '../datasources/habit_local_datasource.dart';
import '../models/habit_model.dart';

@LazySingleton(as: IHabitRepository)
class HabitRepositoryImpl implements IHabitRepository {
  final IHabitLocalDataSource _dataSource;

  const HabitRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Habit>>> getAll() async {
    try {
      final models = await _dataSource.getAll();
      return Right(models.map((m) => m.toDomain()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Habit>> getById(String id) async {
    try {
      final model = await _dataSource.getById(id);
      return Right(model.toDomain());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> add(Habit habit) async {
    try {
      await _dataSource.save(HabitModel.fromDomain(habit));
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> update(Habit habit) async {
    try {
      await _dataSource.getById(habit.id); // existence check
      await _dataSource.save(HabitModel.fromDomain(habit));
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleCompletion(
      String id, DateTime date) async {
    try {
      final model = await _dataSource.getById(id);
      final habit = model.toDomain();
      final dateOnly = DateTime(date.year, date.month, date.day);

      final alreadyDone =
          habit.completedDates.any((d) => _sameDay(d, dateOnly));

      final updated = habit.copyWith(
        completedDates: alreadyDone
            ? habit.completedDates
                .where((d) => !_sameDay(d, dateOnly))
                .toList()
            : [...habit.completedDates, dateOnly],
      );

      await _dataSource.save(HabitModel.fromDomain(updated));
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
