import 'package:hive/hive.dart';

import '../../domain/entities/habit.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 3)
class HabitModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String iconName;

  @HiveField(3)
  String? description;

  @HiveField(4)
  late int frequencyIndex; // HabitFrequency.index

  @HiveField(5)
  late List<int> weekDays;

  @HiveField(6)
  late DateTime startDate;

  @HiveField(7)
  late List<DateTime> completedDates;

  @HiveField(8)
  late String colorHex;

  Habit toDomain() => Habit(
        id: id,
        name: name,
        iconName: iconName,
        description: description,
        frequency: HabitFrequency.values[frequencyIndex],
        weekDays: List<int>.from(weekDays),
        startDate: startDate,
        completedDates: List<DateTime>.from(completedDates),
        colorHex: colorHex,
      );

  static HabitModel fromDomain(Habit h) => HabitModel()
    ..id = h.id
    ..name = h.name
    ..iconName = h.iconName
    ..description = h.description
    ..frequencyIndex = h.frequency.index
    ..weekDays = List<int>.from(h.weekDays)
    ..startDate = h.startDate
    ..completedDates = List<DateTime>.from(h.completedDates)
    ..colorHex = h.colorHex;
}
