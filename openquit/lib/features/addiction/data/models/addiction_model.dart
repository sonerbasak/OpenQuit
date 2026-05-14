import 'package:hive/hive.dart';

import '../../domain/entities/addiction.dart';

part 'addiction_model.g.dart';

/// Hive-persisted data model for an addiction.
///
/// TypeId 0 is reserved for this model — never reuse it.
/// The domain layer never sees Hive annotations; it only works with
/// the pure [Addiction] entity returned by [toDomain()].
@HiveType(typeId: 0)
class AddictionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String iconName;

  @HiveField(3)
  late DateTime startDate;

  @HiveField(4)
  late double costPerDay;

  @HiveField(5)
  late int minutesWastedPerDay;

  // ─── Mapping ──────────────────────────────────────────────────────────────

  /// Converts this model to the pure domain [Addiction] entity.
  Addiction toDomain() => Addiction(
        id: id,
        name: name,
        iconName: iconName,
        startDate: startDate,
        costPerDay: costPerDay,
        minutesWastedPerDay: minutesWastedPerDay,
      );

  /// Creates an [AddictionModel] from a domain [Addiction] entity.
  static AddictionModel fromDomain(Addiction addiction) {
    final model = AddictionModel()
      ..id = addiction.id
      ..name = addiction.name
      ..iconName = addiction.iconName
      ..startDate = addiction.startDate
      ..costPerDay = addiction.costPerDay
      ..minutesWastedPerDay = addiction.minutesWastedPerDay;
    return model;
  }
}
