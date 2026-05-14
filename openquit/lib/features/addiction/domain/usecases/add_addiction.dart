import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/addiction.dart';
import '../repositories/i_addiction_repository.dart';

/// Validates and persists a new addiction to local storage.
///
/// Business rules enforced here (not in the UI):
/// - Name must not be empty.
/// - [costPerDay] must be >= 0.
/// - [minutesWastedPerDay] must be >= 0.
/// - [startDate] must not be in the future.
@lazySingleton
class AddAddiction implements UseCase<Unit, AddAddictionParams> {
  final IAddictionRepository _repository;

  const AddAddiction(this._repository);

  @override
  Future<Either<Failure, Unit>> call(AddAddictionParams params) async {
    // ── Validation ────────────────────────────────────────────────────────
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
    if (params.startDate.isAfter(DateTime.now())) {
      return const Left(
        ValidationFailure('Start date cannot be in the future.'),
      );
    }

    return _repository.add(params.toEntity());
  }
}

/// Parameters for [AddAddiction].
class AddAddictionParams extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final DateTime startDate;
  final double costPerDay;
  final int minutesWastedPerDay;

  const AddAddictionParams({
    required this.id,
    required this.name,
    required this.iconName,
    required this.startDate,
    required this.costPerDay,
    required this.minutesWastedPerDay,
  });

  Addiction toEntity() => Addiction(
        id: id,
        name: name,
        iconName: iconName,
        startDate: startDate,
        costPerDay: costPerDay,
        minutesWastedPerDay: minutesWastedPerDay,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        startDate,
        costPerDay,
        minutesWastedPerDay,
      ];
}
