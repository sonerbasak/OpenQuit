import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/addiction.dart';
import '../../domain/repositories/i_addiction_repository.dart';
import '../datasources/addiction_local_datasource.dart';
import '../models/addiction_model.dart';

/// Concrete implementation of [IAddictionRepository].
///
/// This class is the bridge between the data layer (Isar models, exceptions)
/// and the domain layer (entities, failures).
///
/// Responsibilities:
/// - Call the data source
/// - Catch typed exceptions and map them to [Failure]s
/// - Map [AddictionModel] ↔ [Addiction] entity
/// - Return [Either<Failure, T>] — never throw
@LazySingleton(as: IAddictionRepository)
class AddictionRepositoryImpl implements IAddictionRepository {
  final IAddictionLocalDataSource _dataSource;

  const AddictionRepositoryImpl(this._dataSource);

  // ─── Read ──────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Addiction>>> getAll() async {
    try {
      final models = await _dataSource.getAll();
      final entities = models.map((m) => m.toDomain()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Addiction>> getById(String id) async {
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

  // ─── Write ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, Unit>> add(Addiction addiction) async {
    try {
      final model = AddictionModel.fromDomain(addiction);
      await _dataSource.save(model);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> update(Addiction addiction) async {
    try {
      // Verify it exists first — getById throws NotFoundException if not
      await _dataSource.getById(addiction.id);
      final model = AddictionModel.fromDomain(addiction);
      await _dataSource.save(model);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

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
}
