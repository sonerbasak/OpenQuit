import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../models/settings_model.dart';
import '../../domain/entities/app_settings.dart';

abstract interface class ISettingsDataSource {
  AppSettings load();
  Future<void> save(AppSettings settings);
}

@LazySingleton(as: ISettingsDataSource)
class HiveSettingsDataSource implements ISettingsDataSource {
  static const String boxName = 'settings';
  static const String _key = 'app_settings';

  final Box<SettingsModel> _box;

  const HiveSettingsDataSource(this._box);

  @override
  AppSettings load() {
    final model = _box.get(_key);
    return model?.toDomain() ?? const AppSettings();
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _box.put(_key, SettingsModel.fromDomain(settings));
  }
}
