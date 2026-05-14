import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/addiction.dart';
import '../repositories/i_addiction_repository.dart';

/// Updates an existing addiction in local storage.
///
/// Applies the same validation rules as [AddAddiction].
@lazySingleton
class UpdateAddiction implements UseCase<Unit, Addiction> {
  final IAddictionRepository _repository;

  const UpdateAddiction(this._repository);

  @override
  Future<Either<Failure, Unit>> call(Addiction params) async {
    if (params.name.trim().isEmpty) {
      return const Left(ValidationFailure('Addiction name cannot be empty.'));
    }
    if (params.costPerDay < 0) {
      return const Left(ValidationFailure('Cost per day cannot be negative.'));
    }
    if (params.minutesWastedPerDay < 0) {
      return const Left(
        ValidationFailure('Minutes wasted per day cannot be negative.'),
      );
    }

    return _repository.update(params);
  }
}
