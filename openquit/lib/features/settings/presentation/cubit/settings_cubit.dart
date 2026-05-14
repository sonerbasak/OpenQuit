import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/settings_datasource.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/currency.dart';

part 'settings_state.dart';

@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  final ISettingsDataSource _ds;

  SettingsCubit(this._ds) : super(const SettingsState(AppSettings()));

  void load() => emit(SettingsState(_ds.load()));

  Future<void> setCurrency(Currency currency) async {
    final updated = state.settings.copyWith(
      currencyCode: currency.code,
      currencySymbol: currency.symbol,
    );
    await _ds.save(updated);
    emit(SettingsState(updated));
  }

  Future<void> setDailyMotivation({required bool enabled}) async {
    final updated =
        state.settings.copyWith(dailyMotivationEnabled: enabled);
    await _ds.save(updated);
    emit(SettingsState(updated));
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    final updated = state.settings.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );
    await _ds.save(updated);
    emit(SettingsState(updated));
  }

  Future<void> setMilestoneNotifications({required bool enabled}) async {
    final updated =
        state.settings.copyWith(milestoneNotificationsEnabled: enabled);
    await _ds.save(updated);
    emit(SettingsState(updated));
  }
}
