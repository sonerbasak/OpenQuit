import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
///
/// Every use case returns [Either<Failure, T>] so the presentation
/// layer never has to deal with raw exceptions.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Concrete Failures ────────────────────────────────────────────────────────

/// Thrown when a local database operation fails.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A local storage error occurred.']);
}

/// Thrown when a requested entity is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested item was not found.']);
}

/// Thrown when input data fails validation.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Thrown for any unexpected / unclassified error.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
