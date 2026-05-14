import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/habit.dart';
import '../cubit/habit_list_cubit.dart';
import 'add_habit_sheet.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({super.key, required this.habit});

  Color get _color =>
      Color(int.parse('FF${habit.colorHex}', radix: 16));

  IconData _iconData(String name) {
    const map = {
      'self_improvement': Icons.self_improvement_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'menu_book': Icons.menu_book_rounded,
      'water_drop': Icons.water_drop_rounded,
      'bedtime': Icons.bedtime_rounded,
      'directions_run': Icons.directions_run_rounded,
      'restaurant': Icons.restaurant_rounded,
      'favorite': Icons.favorite_rounded,
      'psychology': Icons.psychology_rounded,
      'music_note': Icons.music_note_rounded,
      'brush': Icons.brush_rounded,
      'code': Icons.code_rounded,
    };
    return map[name] ?? Icons.star_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = habit.isScheduledToday;
    final isDone = habit.isCompletedToday;
    final streak = habit.currentStreak;

    return Dismissible(
      key: ValueKey(habit.id),
      direction: DismissDirection.endToStart,
      background: _DeleteBackground(),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          context.read<HabitListCubit>().deleteHabit(habit.id),
      child: GestureDetector(
        onLongPress: () => AddHabitSheet.show(context, existing: habit),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDone
                  ? _color.withAlpha(80)
                  : Colors.white.withAlpha(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // ── Icon ──────────────────────────────────────────────────
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _color.withAlpha(isDone ? 50 : 25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _iconData(habit.iconName),
                    color: _color.withAlpha(isDone ? 255 : 160),
                    size: 24,
                  ),
                ),
                const Gap(14),

                // ── Info ──────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: TextStyle(
                          color: Colors.white.withAlpha(isDone ? 255 : 200),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: Colors.white.withAlpha(80),
                        ),
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          _FrequencyChip(habit: habit, color: _color),
                          if (streak > 0) ...[
                            const Gap(6),
                            _StreakBadge(streak: streak),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Completion toggle ─────────────────────────────────────
                if (isToday)
                  GestureDetector(
                    onTap: () => context
                        .read<HabitListCubit>()
                        .toggleCompletion(habit.id, DateTime.now()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDone ? _color : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone
                              ? _color
                              : Colors.white.withAlpha(60),
                          width: 2,
                        ),
                        boxShadow: isDone
                            ? [
                                BoxShadow(
                                  color: _color.withAlpha(80),
                                  blurRadius: 10,
                                )
                              ]
                            : null,
                      ),
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  )
                else
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withAlpha(20), width: 2),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: Colors.white.withAlpha(40),
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete habit?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'All progress for "${habit.name}" will be lost.',
          style: TextStyle(color: Colors.white.withAlpha(160)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: TextStyle(color: Colors.white.withAlpha(160))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFFF4D6D))),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D6D).withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline_rounded,
          color: Color(0xFFFF4D6D), size: 26),
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  final Habit habit;
  final Color color;

  const _FrequencyChip({required this.habit, required this.color});

  String get _label {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.custom:
        final days = habit.weekDays.map(_dayName).join(', ');
        return days;
    }
  }

  String _dayName(int d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: color.withAlpha(200),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8008).withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 11)),
          const Gap(3),
          Text(
            '$streak',
            style: const TextStyle(
              color: Color(0xFFFF8008),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
