// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:hive/hive.dart' as _i8;
import 'package:hive_flutter/hive_flutter.dart' as _i3;
import 'package:injectable/injectable.dart' as _i2;

import '../../features/addiction/data/datasources/addiction_local_datasource.dart'
    as _i7;
import '../../features/addiction/data/datasources/relapse_local_datasource.dart'
    as _i11;
import '../../features/addiction/data/models/addiction_model.dart' as _i4;
import '../../features/addiction/data/models/relapse_model.dart' as _i6;
import '../../features/addiction/data/repositories/addiction_repository_impl.dart'
    as _i10;
import '../../features/addiction/domain/repositories/i_addiction_repository.dart'
    as _i9;
import '../../features/addiction/domain/usecases/add_addiction.dart' as _i18;
import '../../features/addiction/domain/usecases/delete_addiction.dart' as _i19;
import '../../features/addiction/domain/usecases/get_addiction_stats.dart'
    as _i20;
import '../../features/addiction/domain/usecases/get_all_addictions.dart'
    as _i21;
import '../../features/addiction/domain/usecases/update_addiction.dart' as _i17;
import '../../features/addiction/presentation/cubit/addiction_list/addiction_list_cubit.dart'
    as _i22;
import '../../features/addiction/presentation/cubit/addiction_stats/addiction_stats_cubit.dart'
    as _i23;
import '../../features/addiction/presentation/cubit/relapse/relapse_cubit.dart'
    as _i15;
import '../../features/habits/data/datasources/habit_local_datasource.dart'
    as _i25;
import '../../features/habits/data/models/habit_model.dart' as _i26;
import '../../features/habits/data/repositories/habit_repository_impl.dart'
    as _i28;
import '../../features/habits/domain/repositories/i_habit_repository.dart'
    as _i27;
import '../../features/habits/domain/usecases/add_habit.dart' as _i29;
import '../../features/habits/domain/usecases/delete_habit.dart' as _i30;
import '../../features/habits/domain/usecases/get_all_habits.dart' as _i31;
import '../../features/habits/domain/usecases/toggle_habit_completion.dart'
    as _i32;
import '../../features/habits/domain/usecases/update_habit.dart' as _i33;
import '../../features/habits/presentation/cubit/habit_list_cubit.dart'
    as _i34;
import '../../features/settings/data/datasources/settings_datasource.dart'
    as _i12;
import '../../features/settings/data/models/settings_model.dart' as _i5;
import '../../features/settings/presentation/cubit/settings_cubit.dart' as _i16;
import '../milestones/milestone_tracker.dart' as _i13;
import '../notifications/notification_service.dart' as _i14;
import 'hive_module.dart' as _i24;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final hiveModule = _$HiveModule();
    await gh.lazySingletonAsync<_i3.Box<_i4.AddictionModel>>(
      () => hiveModule.addictionBox,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i3.Box<_i5.SettingsModel>>(
      () => hiveModule.settingsBox,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i3.Box<_i6.RelapseModel>>(
      () => hiveModule.relapseBox,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i3.Box<bool>>(
      () => hiveModule.milestoneTrackerBox,
      preResolve: true,
    );
    await gh.lazySingletonAsync<_i3.Box<_i26.HabitModel>>(
      () => hiveModule.habitBox,
      preResolve: true,
    );
    gh.lazySingleton<_i7.IAddictionLocalDataSource>(() =>
        _i7.HiveAddictionLocalDataSource(gh<_i8.Box<_i4.AddictionModel>>()));
    gh.lazySingleton<_i9.IAddictionRepository>(() =>
        _i10.AddictionRepositoryImpl(gh<_i7.IAddictionLocalDataSource>()));
    gh.lazySingleton<_i11.IRelapseLocalDataSource>(
        () => _i11.HiveRelapseLocalDataSource(gh<_i8.Box<_i6.RelapseModel>>()));
    gh.lazySingleton<_i12.ISettingsDataSource>(
        () => _i12.HiveSettingsDataSource(gh<_i8.Box<_i5.SettingsModel>>()));
    gh.lazySingleton<_i13.MilestoneTracker>(
        () => _i13.MilestoneTracker(gh<_i8.Box<bool>>()));
    gh.lazySingleton<_i14.NotificationService>(
        () => _i14.NotificationService());
    gh.factory<_i15.RelapseCubit>(() => _i15.RelapseCubit(
          gh<_i11.IRelapseLocalDataSource>(),
          gh<_i9.IAddictionRepository>(),
        ));
    gh.lazySingleton<_i16.SettingsCubit>(
        () => _i16.SettingsCubit(gh<_i12.ISettingsDataSource>()));
    gh.lazySingleton<_i17.UpdateAddiction>(
        () => _i17.UpdateAddiction(gh<_i9.IAddictionRepository>()));
    gh.lazySingleton<_i18.AddAddiction>(
        () => _i18.AddAddiction(gh<_i9.IAddictionRepository>()));
    gh.lazySingleton<_i19.DeleteAddiction>(
        () => _i19.DeleteAddiction(gh<_i9.IAddictionRepository>()));
    gh.lazySingleton<_i20.GetAddictionStats>(
        () => _i20.GetAddictionStats(gh<_i9.IAddictionRepository>()));
    gh.lazySingleton<_i21.GetAllAddictions>(
        () => _i21.GetAllAddictions(gh<_i9.IAddictionRepository>()));
    gh.factory<_i22.AddictionListCubit>(() => _i22.AddictionListCubit(
          gh<_i21.GetAllAddictions>(),
          gh<_i18.AddAddiction>(),
          gh<_i19.DeleteAddiction>(),
        ));
    gh.factory<_i23.AddictionStatsCubit>(() => _i23.AddictionStatsCubit(
          gh<_i20.GetAddictionStats>(),
          gh<_i17.UpdateAddiction>(),
        ));
    // ── Habits ──────────────────────────────────────────────────────────────
    gh.lazySingleton<_i25.IHabitLocalDataSource>(
        () => _i25.HiveHabitLocalDataSource(gh<_i8.Box<_i26.HabitModel>>()));
    gh.lazySingleton<_i27.IHabitRepository>(
        () => _i28.HabitRepositoryImpl(gh<_i25.IHabitLocalDataSource>()));
    gh.lazySingleton<_i31.GetAllHabits>(
        () => _i31.GetAllHabits(gh<_i27.IHabitRepository>()));
    gh.lazySingleton<_i29.AddHabit>(
        () => _i29.AddHabit(gh<_i27.IHabitRepository>()));
    gh.lazySingleton<_i33.UpdateHabit>(
        () => _i33.UpdateHabit(gh<_i27.IHabitRepository>()));
    gh.lazySingleton<_i30.DeleteHabit>(
        () => _i30.DeleteHabit(gh<_i27.IHabitRepository>()));
    gh.lazySingleton<_i32.ToggleHabitCompletion>(
        () => _i32.ToggleHabitCompletion(gh<_i27.IHabitRepository>()));
    gh.factory<_i34.HabitListCubit>(() => _i34.HabitListCubit(
          gh<_i31.GetAllHabits>(),
          gh<_i29.AddHabit>(),
          gh<_i33.UpdateHabit>(),
          gh<_i30.DeleteHabit>(),
          gh<_i32.ToggleHabitCompletion>(),
        ));
    return this;
  }
}

class _$HiveModule extends _i24.HiveModule {}
