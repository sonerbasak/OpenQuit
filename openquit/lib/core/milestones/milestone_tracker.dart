import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

/// Hangi milestone'ların bildirim gönderildiğini kalıcı olarak saklar.
///
/// Uygulama yeniden başlatılsa bile aynı milestone iki kez kutlanmaz.
/// Relapse sonrası sıfırlanır — yeni sayaç yeni kutlamalar demektir.
@lazySingleton
class MilestoneTracker {
  static const String _prefix = 'ms_';

  final Box<bool> _box;

  const MilestoneTracker(this._box);

  /// Bu milestone + addiction kombinasyonu daha önce kutlandı mı?
  bool wasNotified(String addictionId, String milestoneId) {
    return _box.get('$_prefix${addictionId}_$milestoneId') ?? false;
  }

  /// Kutlandı olarak işaretle.
  Future<void> markNotified(String addictionId, String milestoneId) async {
    await _box.put('$_prefix${addictionId}_$milestoneId', true);
  }

  /// Relapse sonrası tüm milestone'ları sıfırla.
  Future<void> resetForAddiction(String addictionId) async {
    final keys = _box.keys
        .where((k) => k.toString().startsWith('$_prefix${addictionId}_'))
        .toList();
    if (keys.isNotEmpty) await _box.deleteAll(keys);
  }
}
