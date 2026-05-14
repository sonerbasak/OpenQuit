import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Contract for all use cases that accept [Params] and return [Type].
///
/// Usage:
/// ```dart
/// class GetAddictions implements UseCase<List<Addiction>, NoParams> { ... }
/// ```
abstract interface class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}

/// Sentinel type for use cases that require no parameters.
class NoParams {
  const NoParams();
}
