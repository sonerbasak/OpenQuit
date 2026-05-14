import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/addiction.dart';

/// Abstract contract for all addiction data operations.
///
/// The domain layer depends on this interface — never on a concrete
/// implementation. This enforces the Dependency Inversion Principle (DIP)
/// and makes the data layer fully swappable (Isar → Hive → SQLite, etc.)
/// without touching a single line of domain or presentation code.
abstract interface class IAddictionRepository {
  /// Returns all tracked addictions, ordered by [Addiction.startDate] desc.
  ///
  /// Returns [CacheFailure] if the local database cannot be read.
  Future<Either<Failure, List<Addiction>>> getAll();

  /// Returns a single addiction by its [id].
  ///
  /// Returns [NotFoundFailure] if no addiction with that id exists.
  /// Returns [CacheFailure] on a database error.
  Future<Either<Failure, Addiction>> getById(String id);

  /// Persists a new [addiction] to local storage.
  ///
  /// Returns [ValidationFailure] if the entity fails business-rule validation.
  /// Returns [CacheFailure] on a database error.
  Future<Either<Failure, Unit>> add(Addiction addiction);

  /// Updates an existing addiction.
  ///
  /// Returns [NotFoundFailure] if the addiction does not exist.
  /// Returns [CacheFailure] on a database error.
  Future<Either<Failure, Unit>> update(Addiction addiction);

  /// Permanently deletes the addiction with the given [id].
  ///
  /// Returns [NotFoundFailure] if no addiction with that id exists.
  /// Returns [CacheFailure] on a database error.
  Future<Either<Failure, Unit>> delete(String id);
}
