import 'package:equatable/equatable.dart';

/// Core domain entity representing a tracked addiction.
///
/// This is a pure Dart class — no framework dependencies, no annotations.
/// It lives only in the domain layer and is the single source of truth
/// for what an "addiction" means in this application.
class Addiction extends Equatable {
  /// Unique identifier (UUID v4).
  final String id;

  /// Human-readable name, e.g. "Smoking", "Alcohol".
  final String name;

  /// Icon identifier — maps to a named icon in the UI layer.
  /// Stored as a string so the domain stays UI-agnostic.
  final String iconName;

  /// The moment the user started tracking this addiction (quit date).
  ///
  /// ⚡ Battery-efficient design: we store this timestamp once and
  /// compute elapsed time on-demand via [DateTime.now().difference(startDate)]
  /// instead of running a background timer.
  final DateTime startDate;

  /// Estimated money spent per day on this addiction (in user's currency).
  final double costPerDay;

  /// Estimated time wasted per day on this addiction (in minutes).
  final int minutesWastedPerDay;

  const Addiction({
    required this.id,
    required this.name,
    required this.iconName,
    required this.startDate,
    required this.costPerDay,
    required this.minutesWastedPerDay,
  });

  /// Returns how long the user has been clean — calculated fresh each call.
  /// No timers, no streams — just a simple subtraction.
  Duration get sobrietyDuration => DateTime.now().difference(startDate);

  /// Total money saved since [startDate], based on [costPerDay].
  double get moneySaved {
    final days = sobrietyDuration.inSeconds / 86400.0;
    return days * costPerDay;
  }

  /// Total time saved since [startDate], based on [minutesWastedPerDay].
  Duration get timeSaved {
    final days = sobrietyDuration.inSeconds / 86400.0;
    final savedMinutes = (days * minutesWastedPerDay).floor();
    return Duration(minutes: savedMinutes);
  }

  /// Returns a copy of this entity with the given fields replaced.
  Addiction copyWith({
    String? id,
    String? name,
    String? iconName,
    DateTime? startDate,
    double? costPerDay,
    int? minutesWastedPerDay,
  }) {
    return Addiction(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      startDate: startDate ?? this.startDate,
      costPerDay: costPerDay ?? this.costPerDay,
      minutesWastedPerDay: minutesWastedPerDay ?? this.minutesWastedPerDay,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        startDate,
        costPerDay,
        minutesWastedPerDay,
      ];

  @override
  String toString() =>
      'Addiction(id: $id, name: $name, startDate: $startDate)';
}
