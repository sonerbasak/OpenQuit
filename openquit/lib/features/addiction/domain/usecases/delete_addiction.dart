import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_addiction_repository.dart';

/// Permanently deletes an addiction from local storage.
@lazySingleton
class DeleteAddiction implements UseCase<Unit, DeleteAddictionParams> {
  final IAddictionRepository _repository;

  const DeleteAddiction(this._repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteAddictionParams params) {
    return _repository.delete(params.id);
  }
}

/// Parameters for [DeleteAddiction].
class DeleteAddictionParams extends Equatable {
  final String id;

  const DeleteAddictionParams({required this.id});

  @override
  List<Object?> get props => [id];
}
