/// Utility class responsible for all duration and time-related formatting.
///
/// No logic lives in the UI — all formatting is delegated here.
/// This class is intentionally stateless and uses only static methods.
abstract final class DurationFormatter {
  // Approximate constants for month/year calculations
  static const int _daysInYear = 365;
  static const int _daysInMonth = 30;

  /// Breaks a [Duration] into human-readable components.
  ///
  /// Returns a [FormattedDuration] value object with individual fields
  /// so the UI can compose the display string however it likes.
  static FormattedDuration breakdown(Duration duration) {
    int totalDays = duration.inDays;
    final int years = totalDays ~/ _daysInYear;
    totalDays -= years * _daysInYear;
    final int months = totalDays ~/ _daysInMonth;
    totalDays -= months * _daysInMonth;
    final int days = totalDays;
    final int hours = duration.inHours % 24;
    final int minutes = duration.inMinutes % 60;
    final int seconds = duration.inSeconds % 60;

    return FormattedDuration(
      years: years,
      months: months,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  /// Returns a compact string: `"2y 3mo 5d"` or `"4h 12min 30s"`.
  static String toCompactString(Duration duration) {
    final fd = breakdown(duration);

    if (fd.years > 0) return '${fd.years}y ${fd.months}mo ${fd.days}d';
    if (fd.months > 0) return '${fd.months}mo ${fd.days}d ${fd.hours}h';
    if (fd.days > 0) return '${fd.days}d ${fd.hours}h ${fd.minutes}min';
    if (fd.hours > 0) return '${fd.hours}h ${fd.minutes}min ${fd.seconds}s';
    if (fd.minutes > 0) return '${fd.minutes}min ${fd.seconds}s';
    return '${fd.seconds}s';
  }

  /// Returns a verbose string:
  /// `"2 years, 3 months, 5 days, 4 hours, 12 minutes, 30 seconds"`
  static String toVerboseString(Duration duration) {
    final fd = breakdown(duration);
    final parts = <String>[];

    if (fd.years > 0) parts.add('${fd.years} ${_plural(fd.years, 'year')}');
    if (fd.months > 0) parts.add('${fd.months} ${_plural(fd.months, 'month')}');
    if (fd.days > 0) parts.add('${fd.days} ${_plural(fd.days, 'day')}');
    if (fd.hours > 0) parts.add('${fd.hours} ${_plural(fd.hours, 'hour')}');
    if (fd.minutes > 0) {
      parts.add('${fd.minutes} ${_plural(fd.minutes, 'minute')}');
    }
    if (fd.seconds > 0) {
      parts.add('${fd.seconds} ${_plural(fd.seconds, 'second')}');
    }

    return parts.isEmpty ? '0 seconds' : parts.join(', ');
  }

  /// Formats a monetary value: `formatMoney(1234.5)` → `"$1,234.50"`
  static String formatMoney(double amount, {String symbol = '\$'}) {
    final isNegative = amount < 0;
    final abs = amount.abs();
    final parts = abs.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }

    return '${isNegative ? '-' : ''}$symbol$buffer.$decPart';
  }

  static String _plural(int count, String singular) =>
      count == 1 ? singular : '${singular}s';
}

/// Immutable value object holding the broken-down components of a [Duration].
final class FormattedDuration {
  final int years;
  final int months;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  const FormattedDuration({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  @override
  String toString() =>
      '${years}y ${months}mo ${days}d ${hours}h ${minutes}min ${seconds}s';
}
