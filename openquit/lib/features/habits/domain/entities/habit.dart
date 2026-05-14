import 'package:equatable/equatable.dart';

/// Bir alışkanlığın tekrar sıklığını tanımlar.
enum HabitFrequency {
  /// Her gün
  daily,

  /// Haftanın belirli günleri — [weekDays] listesi kullanılır
  weekly,

  /// Kullanıcının seçtiği özel günler — [weekDays] listesi kullanılır
  custom,
}

/// Pure domain entity — bir alışkanlık kaydı.
///
/// Hiçbir framework bağımlılığı yok.
class Habit extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final String? description;
  final HabitFrequency frequency;

  /// Haftanın hangi günlerinde yapılacak (1=Pazartesi … 7=Pazar).
  /// [HabitFrequency.daily] için boş liste — her gün geçerli.
  final List<int> weekDays;

  /// Alışkanlığın başladığı tarih.
  final DateTime startDate;

  /// Hangi günlerde tamamlandığı — sadece tarih (saat yok).
  final List<DateTime> completedDates;

  /// Renk kodu (hex string, örn. "7C5CFC").
  final String colorHex;

  const Habit({
    required this.id,
    required this.name,
    required this.iconName,
    this.description,
    required this.frequency,
    required this.weekDays,
    required this.startDate,
    required this.completedDates,
    required this.colorHex,
  });

  // ─── Computed properties ──────────────────────────────────────────────────

  /// Bugün bu alışkanlık yapılması gereken bir gün mü?
  bool get isScheduledToday => isScheduledOn(DateTime.now());

  /// Weekly alışkanlık bu hafta içinde tamamlandı mı?
  bool get isCompletedThisWeek {
    final now = DateTime.now();
    // Haftanın başı: Pazartesi
    final weekStart = _dateOnly(now.subtract(Duration(days: now.weekday - 1)));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return completedDates.any((d) {
      final day = _dateOnly(d);
      return !day.isBefore(weekStart) && !day.isAfter(weekEnd);
    });
  }

  /// Verilen gün bu alışkanlık yapılması gereken bir gün mü?
  bool isScheduledOn(DateTime date) {
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        // Haftada bir kez — her gün "yapılabilir" sayılır,
        // o hafta içinde zaten bir kez tamamlandıysa kart pasif görünür.
        return true;
      case HabitFrequency.custom:
        return weekDays.contains(date.weekday);
    }
  }

  /// Verilen gün tamamlandı mı?
  bool isCompletedOn(DateTime date) {
    final d = _dateOnly(date);
    return completedDates.any((c) => _dateOnly(c) == d);
  }

  /// Bugün tamamlandı mı?
  /// Weekly alışkanlıklar için: bu hafta içinde herhangi bir gün tamamlandıysa true.
  bool get isCompletedToday {
    if (frequency == HabitFrequency.weekly) return isCompletedThisWeek;
    return isCompletedOn(DateTime.now());
  }

  /// Mevcut streak (ardışık tamamlanan gün sayısı).
  int get currentStreak {
    int streak = 0;
    var day = _dateOnly(DateTime.now());

    // Bugün tamamlanmadıysa dünden başla
    if (!isCompletedOn(day) || !isScheduledOn(day)) {
      day = day.subtract(const Duration(days: 1));
    }

    while (true) {
      if (!isScheduledOn(day)) {
        // Planlanmamış gün — atla, streak'i kırma
        day = day.subtract(const Duration(days: 1));
        // Başlangıç tarihinden önceye gitme
        if (day.isBefore(_dateOnly(startDate))) break;
        continue;
      }
      if (isCompletedOn(day)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
        if (day.isBefore(_dateOnly(startDate))) break;
      } else {
        break;
      }
    }
    return streak;
  }

  /// En uzun streak.
  int get longestStreak {
    int longest = 0;
    int current = 0;
    final start = _dateOnly(startDate);
    final today = _dateOnly(DateTime.now());

    var day = start;
    while (!day.isAfter(today)) {
      if (!isScheduledOn(day)) {
        day = day.add(const Duration(days: 1));
        continue;
      }
      if (isCompletedOn(day)) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
      day = day.add(const Duration(days: 1));
    }
    return longest;
  }

  /// Toplam tamamlanma sayısı.
  int get totalCompletions => completedDates.length;

  /// Başlangıçtan bugüne kadar planlanmış gün sayısı.
  int get totalScheduledDays {
    int count = 0;
    final start = _dateOnly(startDate);
    final today = _dateOnly(DateTime.now());
    var day = start;
    while (!day.isAfter(today)) {
      if (isScheduledOn(day)) count++;
      day = day.add(const Duration(days: 1));
    }
    return count;
  }

  /// Tamamlanma oranı (0.0–1.0).
  double get completionRate {
    if (totalScheduledDays == 0) return 0;
    return (totalCompletions / totalScheduledDays).clamp(0.0, 1.0);
  }

  Habit copyWith({
    String? id,
    String? name,
    String? iconName,
    String? description,
    HabitFrequency? frequency,
    List<int>? weekDays,
    DateTime? startDate,
    List<DateTime>? completedDates,
    String? colorHex,
  }) =>
      Habit(
        id: id ?? this.id,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
        description: description ?? this.description,
        frequency: frequency ?? this.frequency,
        weekDays: weekDays ?? this.weekDays,
        startDate: startDate ?? this.startDate,
        completedDates: completedDates ?? this.completedDates,
        colorHex: colorHex ?? this.colorHex,
      );

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  @override
  List<Object?> get props => [
        id,
        name,
        iconName,
        frequency,
        weekDays,
        startDate,
        completedDates,
        colorHex,
      ];
}
