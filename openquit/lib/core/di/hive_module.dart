import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../features/addiction/data/datasources/addiction_local_datasource.dart';
import '../../features/addiction/data/datasources/relapse_local_datasource.dart';
import '../../features/addiction/data/models/addiction_model.dart';
import '../../features/addiction/data/models/relapse_model.dart';
import '../../features/habits/data/datasources/habit_local_datasource.dart';
import '../../features/habits/data/models/habit_model.dart';
import '../../features/settings/data/datasources/settings_datasource.dart';
import '../../features/settings/data/models/settings_model.dart';

@module
abstract class HiveModule {
  @preResolve
  @lazySingleton
  Future<Box<AddictionModel>> get addictionBox async {
    if (!Hive.isAdapterRegistered(0)) {
      await Hive.initFlutter();
      Hive.registerAdapter(AddictionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RelapseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
    if (Hive.isBoxOpen(HiveAddictionLocalDataSource.boxName)) {
      return Hive.box<AddictionModel>(HiveAddictionLocalDataSource.boxName);
    }
    return Hive.openBox<AddictionModel>(HiveAddictionLocalDataSource.boxName);
  }

  @preResolve
  @lazySingleton
  Future<Box<SettingsModel>> get settingsBox async {
    if (Hive.isBoxOpen(HiveSettingsDataSource.boxName)) {
      return Hive.box<SettingsModel>(HiveSettingsDataSource.boxName);
    }
    return Hive.openBox<SettingsModel>(HiveSettingsDataSource.boxName);
  }

  @preResolve
  @lazySingleton
  Future<Box<RelapseModel>> get relapseBox async {
    if (Hive.isBoxOpen(HiveRelapseLocalDataSource.boxName)) {
      return Hive.box<RelapseModel>(HiveRelapseLocalDataSource.boxName);
    }
    return Hive.openBox<RelapseModel>(HiveRelapseLocalDataSource.boxName);
  }

  @preResolve
  @lazySingleton
  Future<Box<bool>> get milestoneTrackerBox async {
    const boxName = 'milestone_tracker';
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<bool>(boxName);
    }
    return Hive.openBox<bool>(boxName);
  }

  @preResolve
  @lazySingleton
  Future<Box<HabitModel>> get habitBox async {
    if (Hive.isBoxOpen(HiveHabitLocalDataSource.boxName)) {
      return Hive.box<HabitModel>(HiveHabitLocalDataSource.boxName);
    }
    return Hive.openBox<HabitModel>(HiveHabitLocalDataSource.boxName);
  }
}
