import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/addiction_model.dart';

/// Contract for the local data source.
abstract interface class IAddictionLocalDataSource {
  Future<List<AddictionModel>> getAll();
  Future<AddictionModel> getById(String id);
  Future<void> save(AddictionModel model);
  Future<void> delete(String id);
}

/// Hive-backed implementation of [IAddictionLocalDataSource].
///
/// Uses the addiction's UUID string as the Hive box key so lookups
/// are O(1) and we never need a secondary index.
@LazySingleton(as: IAddictionLocalDataSource)
class HiveAddictionLocalDataSource implements IAddictionLocalDataSource {
  static const String boxName = 'addictions';

  /// The open Hive box — injected so it can be mocked in tests.
  final Box<AddictionModel> _box;

  const HiveAddictionLocalDataSource(this._box);

  @override
  Future<List<AddictionModel>> getAll() async {
    try {
      final items = _box.values.toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate));
      return items;
    } catch (e) {
      throw CacheException('Failed to read addictions: $e');
    }
  }

  @override
  Future<AddictionModel> getById(String id) async {
    try {
      final model = _box.get(id);
      if (model == null) throw NotFoundException('Addiction "$id" not found.');
      return model;
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to read addiction "$id": $e');
    }
  }

  @override
  Future<void> save(AddictionModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save addiction: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (!_box.containsKey(id)) {
        throw NotFoundException('Addiction "$id" not found.');
      }
      await _box.delete(id);
    } on NotFoundException {
      rethrow;
    } catch (e) {
      throw CacheException('Failed to delete addiction "$id": $e');
    }
  }
}
