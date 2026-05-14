import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/addiction_stats.dart';
import '../../../domain/usecases/get_addiction_stats.dart';
import '../../../domain/usecases/update_addiction.dart';
import '../../../domain/entities/addiction.dart';

part 'addiction_stats_state.dart';

/// Manages the state of the addiction detail / stats screen.
///
/// Stats are recalculated on every [loadStats] call — no background timer.
/// The UI triggers a refresh using a periodic [Timer] only while the screen
/// is visible (started in initState, cancelled in dispose).
@injectable
class AddictionStatsCubit extends Cubit<AddictionStatsState> {
  final GetAddictionStats _getStats;
  final UpdateAddiction _update;

  AddictionStatsCubit(
    this._getStats,
    this._update,
  ) : super(const AddictionStatsInitial());

  /// Fetches and calculates stats for [addictionId].
  /// Call this once on screen open, then every second from the UI timer.
  Future<void> loadStats(String addictionId) async {
    // Don't flash loading on periodic refreshes — only on first load
    if (state is AddictionStatsInitial) {
      emit(const AddictionStatsLoading());
    }

    final result = await _getStats(
      GetAddictionStatsParams(addictionId: addictionId),
    );

    result.fold(
      (failure) => emit(AddictionStatsError(failure.message)),
      (stats) => emit(AddictionStatsLoaded(stats)),
    );
  }

  /// Updates the addiction and reloads stats.
  Future<void> updateAddiction(Addiction addiction) async {
    final result = await _update(addiction);

    result.fold(
      (failure) => emit(AddictionStatsError(failure.message)),
      (_) => loadStats(addiction.id),
    );
  }
}
