import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/relapse_model.dart';

abstract interface class IRelapseLocalDataSource {
  Future<List<RelapseModel>> getByAddictionId(String addictionId);
  Future<void> save(RelapseModel model);
  Future<void> deleteByAddictionId(String addictionId);
}

@LazySingleton(as: IRelapseLocalDataSource)
class HiveRelapseLocalDataSource implements IRelapseLocalDataSource {
  static const String boxName = 'relapses';

  final Box<RelapseModel> _box;

  const HiveRelapseLocalDataSource(this._box);

  @override
  Future<List<RelapseModel>> getByAddictionId(String addictionId) async {
    try {
      return _box.values
          .where((r) => r.addictionId == addictionId)
          .toList()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    } catch (e) {
      throw CacheException('Failed to read relapses: $e');
    }
  }

  @override
  Future<void> save(RelapseModel model) async {
    try {
      await _box.put(model.id, model);
    } catch (e) {
      throw CacheException('Failed to save relapse: $e');
    }
  }

  @override
  Future<void> deleteByAddictionId(String addictionId) async {
    try {
      final keys = _box.values
          .where((r) => r.addictionId == addictionId)
          .map((r) => r.id)
          .toList();
      await _box.deleteAll(keys);
    } catch (e) {
      throw CacheException('Failed to delete relapses: $e');
    }
  }
}
