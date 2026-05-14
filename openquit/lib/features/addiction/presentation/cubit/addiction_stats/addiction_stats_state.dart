part of 'addiction_stats_cubit.dart';

/// States for the addiction detail / stats screen.
sealed class AddictionStatsState extends Equatable {
  const AddictionStatsState();

  @override
  List<Object?> get props => [];
}

final class AddictionStatsInitial extends AddictionStatsState {
  const AddictionStatsInitial();
}

final class AddictionStatsLoading extends AddictionStatsState {
  const AddictionStatsLoading();
}

final class AddictionStatsLoaded extends AddictionStatsState {
  final AddictionStats stats;

  const AddictionStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

final class AddictionStatsError extends AddictionStatsState {
  final String message;

  const AddictionStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
