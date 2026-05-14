import 'package:equatable/equatable.dart';

/// Bir relapse (nüks) kaydı.
///
/// Kullanıcı "Relapsed" butonuna bastığında oluşturulur.
/// Addiction silinmez — sadece [startDate] sıfırlanır ve bu kayıt
/// geçmişe eklenir.
class Relapse extends Equatable {
  /// UUID v4 — benzersiz relapse kimliği.
  final String id;

  /// Hangi addiction'a ait.
  final String addictionId;

  /// Relapse'ın gerçekleştiği an.
  final DateTime occurredAt;

  /// Kullanıcının isteğe bağlı notu.
  final String? note;

  /// Bu relapse öncesindeki sobriety süresi (istatistik için saklanır).
  final Duration previousSobriety;

  const Relapse({
    required this.id,
    required this.addictionId,
    required this.occurredAt,
    required this.previousSobriety,
    this.note,
  });

  @override
  List<Object?> get props => [id, addictionId, occurredAt];
}
