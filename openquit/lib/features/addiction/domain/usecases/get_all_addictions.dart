import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/addiction.dart';
import '../repositories/i_addiction_repository.dart';

/// Returns all tracked addictions from local storage.
///
/// This use case has no parameters — it simply fetches everything.
@lazySingleton
class GetAllAddictions implements UseCase<List<Addiction>, NoParams> {
  final IAddictionRepository _repository;

  const GetAllAddictions(this._repository);

  @override
  Future<Either<Failure, List<Addiction>>> call(NoParams params) {
    return _repository.getAll();
  }
}
