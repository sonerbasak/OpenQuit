/// Bir sobriety milestone'u tanımlar.
class Milestone {
  final String id;
  final String label;       // "1 Day"
  final String emoji;
  final String message;     // kutlama mesajı
  final Duration threshold; // bu süreyi geçince kutlanır

  const Milestone({
    required this.id,
    required this.label,
    required this.emoji,
    required this.message,
    required this.threshold,
  });

  /// Tüm milestone'lar — küçükten büyüğe sıralı.
  static const List<Milestone> all = [
    Milestone(
      id: '6h',
      label: '6 Hours',
      emoji: '🌱',
      message: 'First 6 hours done! Your body is already healing.',
      threshold: Duration(hours: 6),
    ),
    Milestone(
      id: '12h',
      label: '12 Hours',
      emoji: '⚡',
      message: 'Half a day clean! Keep the momentum going.',
      threshold: Duration(hours: 12),
    ),
    Milestone(
      id: '1d',
      label: '1 Day',
      emoji: '🔥',
      message: 'One full day! You proved you can do it.',
      threshold: Duration(days: 1),
    ),
    Milestone(
      id: '3d',
      label: '3 Days',
      emoji: '💪',
      message: '3 days strong! The hardest part is behind you.',
      threshold: Duration(days: 3),
    ),
    Milestone(
      id: '1w',
      label: '1 Week',
      emoji: '🏆',
      message: 'One whole week! You\'re building a new identity.',
      threshold: Duration(days: 7),
    ),
    Milestone(
      id: '2w',
      label: '2 Weeks',
      emoji: '🌟',
      message: '2 weeks! Your brain chemistry is shifting.',
      threshold: Duration(days: 14),
    ),
    Milestone(
      id: '21d',
      label: '21 Days',
      emoji: '🧠',
      message: '21 days — a new habit is forming in your brain!',
      threshold: Duration(days: 21),
    ),
    Milestone(
      id: '1mo',
      label: '1 Month',
      emoji: '🎯',
      message: 'One month free! You\'re a completely different person.',
      threshold: Duration(days: 30),
    ),
    Milestone(
      id: '3mo',
      label: '3 Months',
      emoji: '🦋',
      message: '3 months! Your transformation is visible to everyone.',
      threshold: Duration(days: 90),
    ),
    Milestone(
      id: '6mo',
      label: '6 Months',
      emoji: '🌈',
      message: 'Half a year clean! You\'re an inspiration.',
      threshold: Duration(days: 180),
    ),
    Milestone(
      id: '1y',
      label: '1 Year',
      emoji: '👑',
      message: 'ONE YEAR! You\'ve completely rewritten your story.',
      threshold: Duration(days: 365),
    ),
    Milestone(
      id: '2y',
      label: '2 Years',
      emoji: '🚀',
      message: '2 years! You are unstoppable.',
      threshold: Duration(days: 730),
    ),
  ];

  /// Verilen [sobriety] süresine göre kazanılmış milestone'ları döner.
  static List<Milestone> achieved(Duration sobriety) =>
      all.where((m) => sobriety >= m.threshold).toList();

  /// Bir sonraki kazanılacak milestone'u döner (null = hepsi tamamlandı).
  static Milestone? next(Duration sobriety) {
    try {
      return all.firstWhere((m) => sobriety < m.threshold);
    } catch (_) {
      return null;
    }
  }

  /// Tam olarak bu tick'te geçilen milestone'u döner (saniye hassasiyeti).
  static Milestone? justReached(Duration sobriety) {
    // Bir önceki saniyede geçilmemiş, bu saniyede geçilmiş mi?
    final prev = sobriety - const Duration(seconds: 1);
    try {
      return all.firstWhere(
        (m) => prev < m.threshold && sobriety >= m.threshold,
      );
    } catch (_) {
      return null;
    }
  }
}
