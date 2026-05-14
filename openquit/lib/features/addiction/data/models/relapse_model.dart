import 'package:hive/hive.dart';

import '../../domain/entities/relapse.dart';

part 'relapse_model.g.dart';

@HiveType(typeId: 2)
class RelapseModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String addictionId;

  @HiveField(2)
  late DateTime occurredAt;

  @HiveField(3)
  String? note;

  @HiveField(4)
  late int previousSobrietySeconds;

  Relapse toDomain() => Relapse(
        id: id,
        addictionId: addictionId,
        occurredAt: occurredAt,
        note: note,
        previousSobriety: Duration(seconds: previousSobrietySeconds),
      );

  static RelapseModel fromDomain(Relapse r) => RelapseModel()
    ..id = r.id
    ..addictionId = r.addictionId
    ..occurredAt = r.occurredAt
    ..note = r.note
    ..previousSobrietySeconds = r.previousSobriety.inSeconds;
}
