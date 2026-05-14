import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/addiction_stats.dart';
import '../repositories/i_addiction_repository.dart';

/// Calculates and returns live statistics for a single addiction.
///
/// ⚡ Battery-efficient: all time calculations use stored timestamps.
/// No background timers — stats are computed fresh on each call.
///
/// Returns [AddictionStats] containing:
/// - Sobriety duration
/// - Money saved
/// - Time saved
/// - Daily progress (0.0–1.0) for circular indicators
@lazySingleton
class GetAddictionStats implements UseCase<AddictionStats, GetAddictionStatsParams> {
  final IAddictionRepository _repository;

  const GetAddictionStats(this._repository);

  @override
  Future<Either<Failure, AddictionStats>> call(
    GetAddictionStatsParams params,
  ) async {
    final result = await _repository.getById(params.addictionId);

    return result.fold(
      // Propagate any failure from the repository as-is
      Left.new,
      (addiction) {
        final now = DateTime.now();

        // ── Core time calculation ─────────────────────────────────────────
        // We subtract timestamps — no active timer needed.
        final sobrietyDuration = now.difference(addiction.startDate);

        // ── Money saved ───────────────────────────────────────────────────
        // Fractional days give sub-day precision (e.g. 0.5 days = half cost)
        final fractionalDays = sobrietyDuration.inSeconds / 86400.0;
        final moneySaved = fractionalDays * addiction.costPerDay;

        // ── Time saved ────────────────────────────────────────────────────
        final savedMinutes = (fractionalDays * addiction.minutesWastedPerDay)
            .floor();
        final timeSaved = Duration(minutes: savedMinutes);

        // ── Daily progress (for circular indicator) ───────────────────────
        // How far through the current 24-hour cycle are we? (0.0 – 1.0)
        final secondsIntoCurrentDay = sobrietyDuration.inSeconds % 86400;
        final dailyProgress = secondsIntoCurrentDay / 86400.0;

        return Right(
          AddictionStats(
            addictionId: addiction.id,
            addictionName: addiction.name,
            startDate: addiction.startDate,
            costPerDay: addiction.costPerDay,
            sobrietyDuration: sobrietyDuration,
            moneySaved: moneySaved,
            timeSaved: timeSaved,
            dailyProgress: dailyProgress,
          ),
        );
      },
    );
  }
}

/// Parameters for [GetAddictionStats].
class GetAddictionStatsParams extends Equatable {
  final String addictionId;

  const GetAddictionStatsParams({required this.addictionId});

  @override
  List<Object?> get props => [addictionId];
}
