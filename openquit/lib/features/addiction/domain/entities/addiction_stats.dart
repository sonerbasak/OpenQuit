import 'package:equatable/equatable.dart';

/// Value object that holds all computed statistics for a single addiction.
///
/// Returned by [GetAddictionStatsUseCase]. The presentation layer
/// renders this directly — no calculation logic in widgets.
class AddictionStats extends Equatable {
  final String addictionId;
  final String addictionName;
  final DateTime startDate;
  final double costPerDay;
  final Duration sobrietyDuration;
  final double moneySaved;
  final Duration timeSaved;
  final double dailyProgress;

  const AddictionStats({
    required this.addictionId,
    required this.addictionName,
    required this.startDate,
    required this.costPerDay,
    required this.sobrietyDuration,
    required this.moneySaved,
    required this.timeSaved,
    required this.dailyProgress,
  });

  @override
  List<Object?> get props => [
        addictionId,
        sobrietyDuration,
        moneySaved,
        timeSaved,
        dailyProgress,
      ];
}
