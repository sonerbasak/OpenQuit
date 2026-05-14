import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/relapse.dart';

/// Başarılı günleri ve relapse günlerini gösteren takvim.
///
/// Yeşil = temiz gün, Kırmızı = relapse günü, Gri = henüz gelmemiş.
class SobrietyCalendar extends StatefulWidget {
  final DateTime startDate;
  final List<Relapse> relapses;

  const SobrietyCalendar({
    super.key,
    required this.startDate,
    required this.relapses,
  });

  @override
  State<SobrietyCalendar> createState() => _SobrietyCalendarState();
}

class _SobrietyCalendarState extends State<SobrietyCalendar> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  /// Relapse olan günler (sadece tarih, saat yok)
  Set<DateTime> get _relapseDays => widget.relapses
      .map((r) => _dateOnly(r.occurredAt))
      .toSet();

  /// Başlangıçtan bugüne kadar temiz geçen günler
  Set<DateTime> get _cleanDays {
    final clean = <DateTime>{};
    final start = _dateOnly(widget.startDate);
    final today = _dateOnly(DateTime.now());
    final relapseDays = _relapseDays;

    var cursor = start;
    while (!cursor.isAfter(today)) {
      if (!relapseDays.contains(cursor)) {
        clean.add(cursor);
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return clean;
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    final cleanDays = _cleanDays;
    final relapseDays = _relapseDays;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  'SOBRIETY CALENDAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Colors.white.withAlpha(80),
                  ),
                ),
                const Spacer(),
                _Legend(color: const Color(0xFF38EF7D), label: 'Clean'),
                const SizedBox(width: 12),
                _Legend(color: const Color(0xFFFF4D6D), label: 'Relapse'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TableCalendar<void>(
            firstDay: DateTime(widget.startDate.year - 1, 1, 1),
            lastDay: DateTime.now().add(const Duration(days: 1)),
            focusedDay: _focusedDay,
            onPageChanged: (d) => setState(() => _focusedDay = d),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left_rounded,
                color: Colors.white.withAlpha(180),
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withAlpha(180),
              ),
              headerPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.white.withAlpha(100),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              weekendStyle: TextStyle(
                color: Colors.white.withAlpha(60),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 13,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.white.withAlpha(120),
                fontSize: 13,
              ),
              todayDecoration: BoxDecoration(
                border: Border.all(color: AppTheme.gradientStart, width: 1.5),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.gradientStart,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final d = _dateOnly(day);
                final isClean = cleanDays.contains(d);
                final isRelapse = relapseDays.contains(d);

                if (!isClean && !isRelapse) return null;

                return _DayCell(
                  day: day.day,
                  isClean: isClean,
                  isRelapse: isRelapse,
                );
              },
              todayBuilder: (context, day, focusedDay) {
                final d = _dateOnly(day);
                final isClean = cleanDays.contains(d);
                final isRelapse = relapseDays.contains(d);

                return _DayCell(
                  day: day.day,
                  isClean: isClean,
                  isRelapse: isRelapse,
                  isToday: true,
                );
              },
            ),
          ),

          // ── Stats row ────────────────────────────────────────────────────
          const SizedBox(height: 8),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CalStat(
                value: '${cleanDays.length}',
                label: 'Clean days',
                color: const Color(0xFF38EF7D),
              ),
              _CalStat(
                value: '${relapseDays.length}',
                label: 'Relapses',
                color: const Color(0xFFFF4D6D),
              ),
              _CalStat(
                value: cleanDays.isEmpty
                    ? '0%'
                    : '${((cleanDays.length / (cleanDays.length + relapseDays.length)) * 100).toStringAsFixed(0)}%',
                label: 'Success rate',
                color: AppTheme.gradientStart,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isClean;
  final bool isRelapse;
  final bool isToday;

  const _DayCell({
    required this.day,
    required this.isClean,
    required this.isRelapse,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    if (isRelapse) {
      bg = const Color(0xFFFF4D6D).withAlpha(40);
      textColor = const Color(0xFFFF4D6D);
    } else if (isClean) {
      bg = const Color(0xFF38EF7D).withAlpha(30);
      textColor = const Color(0xFF38EF7D);
    } else {
      bg = Colors.transparent;
      textColor = Colors.white.withAlpha(180);
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(
                color: isRelapse
                    ? const Color(0xFFFF4D6D)
                    : isClean
                        ? const Color(0xFF38EF7D)
                        : AppTheme.gradientStart,
                width: 1.5,
              )
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: isClean || isRelapse || isToday
                ? FontWeight.w700
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withAlpha(120),
          ),
        ),
      ],
    );
  }
}

class _CalStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _CalStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withAlpha(100),
          ),
        ),
      ],
    );
  }
}
