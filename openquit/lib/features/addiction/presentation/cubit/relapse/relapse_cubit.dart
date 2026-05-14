import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/milestones/milestone_tracker.dart';
import '../../../data/datasources/relapse_local_datasource.dart';
import '../../../data/models/relapse_model.dart';
import '../../../domain/entities/relapse.dart';
import '../../../domain/repositories/i_addiction_repository.dart';

part 'relapse_state.dart';

@injectable
class RelapseCubit extends Cubit<RelapseState> {
  final IRelapseLocalDataSource _ds;
  final IAddictionRepository _repo;

  RelapseCubit(this._ds, this._repo) : super(const RelapseState([]));

  MilestoneTracker? _getMilestoneTracker() {
    try {
      return GetIt.instance<MilestoneTracker>();
    } catch (_) {
      return null;
    }
  }

  Future<void> loadRelapses(String addictionId) async {
    final models = await _ds.getByAddictionId(addictionId);
    emit(RelapseState(models.map((m) => m.toDomain()).toList()));
  }

  /// Relapse kaydeder ve addiction'ın startDate'ini şimdiye sıfırlar.
  ///
  /// Önce DB'den gerçek addiction'ı çeker — böylece hiçbir alan kaybolmaz.
  /// Sadece [startDate] güncellenir.
  Future<String?> recordRelapse({
    required String addictionId,
    required Duration previousSobriety,
    String? note,
  }) async {
    // 1. Gerçek addiction'ı DB'den çek
    final result = await _repo.getById(addictionId);
    final addiction = result.fold(
      (failure) => null,
      (a) => a,
    );

    if (addiction == null) return 'Addiction not found.';

    // 2. Relapse kaydını oluştur
    final relapse = RelapseModel.fromDomain(
      Relapse(
        id: const Uuid().v4(),
        addictionId: addictionId,
        occurredAt: DateTime.now(),
        previousSobriety: previousSobriety,
        note: note,
      ),
    );
    await _ds.save(relapse);

    // 3. Sadece startDate'i sıfırla — diğer alanlar korunur
    final reset = addiction.copyWith(startDate: DateTime.now());
    await _repo.update(reset);

    // 4. Milestone tracker'ı sıfırla — yeni sayaç yeni kutlamalar
    // (circular import olmadığı için burada import edebiliriz)
    try {
      final tracker = _getMilestoneTracker();
      await tracker?.resetForAddiction(addictionId);
    } catch (_) {}

    // 5. Relapse listesini güncelle
    await loadRelapses(addictionId);

    return null; // null = başarılı
  }
}
