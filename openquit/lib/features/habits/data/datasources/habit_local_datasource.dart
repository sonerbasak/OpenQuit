import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/habit_model.dart';

abstract interface class IHabitLocalDataSource {
  Future<List<HabitModel>> getAll();
  Future<HabitModel> getById(String id);
  Future<void> save(HabitModel model);
  Future<void> delete(String id);
}

@LazySingleton(as: IHabitLocalDataSource)
class HiveHabitLocalDataSource implements IHabitLocalDataSource {
  static const String boxName = 'habits';

  final Box<HabitModel> _box;

  const HiveHabitLocalDataSource(this._box);

  @override
  Future<List<HabitModel>> getAll() async {
    try {
      return _box.values.toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
    } catch (e) {
      throw CacheException('Failed to read habits: $e');
    }
  }

  @override
  Future<HabitModel> getById(String id) async {
    try {
      final model = _box.get(id);
      if (model == null) throw NotFoundException('Habit "$id" not found.');
      return model;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to read habit "$id": $e');
    }
  }

  @override
  Future<void> save(HabitModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save habit: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (!_box.containsKey(id)) {
        throw NotFoundException('Habit "$id" not found.');
      }
      await _box.delete(id);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to delete habit "$id": $e');
    }
  }
}
