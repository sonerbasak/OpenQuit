import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_theme.dart';

enum ChartPeriod { week, month }

/// Günlük sobriety saatlerini gösteren bar chart.
/// Seçilen periyoda göre haftalık veya aylık görünüm.
class SobrietyChart extends StatefulWidget {
  final DateTime startDate;
  final String currencySymbol;
  final double costPerDay;

  const SobrietyChart({
    super.key,
    required this.startDate,
    required this.currencySymbol,
    required this.costPerDay,
  });

  @override
  State<SobrietyChart> createState() => _SobrietyChartState();
}

class _SobrietyChartState extends State<SobrietyChart> {
  ChartPeriod _period = ChartPeriod.week;
  bool _showMoney = false;

  @override
  Widget build(BuildContext context) {
    final bars = _buildBars();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showMoney ? 'Money Saved' : 'Hours Clean',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _period == ChartPeriod.week
                          ? 'Last 7 days'
                          : 'Last 30 days',
                      style: TextStyle(
                        color: Colors.white.withAlpha(100),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Toggle money/hours
              _ToggleChip(
                label: _showMoney
                    ? '${widget.currencySymbol}'
                    : 'h',
                onTap: () => setState(() => _showMoney = !_showMoney),
              ),
              const SizedBox(width: 8),
              // Period toggle
              _SegmentedControl(
                selected: _period,
                onChanged: (p) => setState(() => _period = p),
              ),
            ],
          ),
          const Gap(20),

          // ── Chart ────────────────────────────────────────────────────────
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _maxY(bars),
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.darkCardHigh,
                    getTooltipItem: (group, _, rod, __) {
                      final val = rod.toY;
                      final label = _showMoney
                          ? '${widget.currencySymbol}${val.toStringAsFixed(2)}'
                          : '${val.toStringAsFixed(1)}h';
                      return BarTooltipItem(
                        label,
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) =>
                          _bottomTitle(value.toInt(), bars.length),
                      reservedSize: 28,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == meta.max) {
                          return Text(
                            _showMoney
                                ? '${widget.currencySymbol}${value.toInt()}'
                                : '${value.toInt()}h',
                            style: TextStyle(
                              color: Colors.white.withAlpha(80),
                              fontSize: 10,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _maxY(bars) / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.white.withAlpha(12),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: bars,
              ),
                swapAnimationDuration: const Duration(milliseconds: 400),
                swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBars() {
    final count = _period == ChartPeriod.week ? 7 : 30;
    final now = DateTime.now();
    final groups = <BarChartGroupData>[];

    for (int i = count - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final value = _valueForDay(day);
      final index = count - 1 - i;
      final isFuture = day.isAfter(now);
      final isToday = i == 0;

      groups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: isFuture ? 0 : value,
              width: _period == ChartPeriod.week ? 22 : 8,
              borderRadius: BorderRadius.circular(6),
              gradient: isFuture
                  ? null
                  : LinearGradient(
                      colors: isToday
                          ? [AppTheme.gradientStart, AppTheme.gradientEnd]
                          : [
                              AppTheme.gradientStart.withAlpha(180),
                              AppTheme.gradientMid.withAlpha(180),
                            ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
              color: isFuture ? Colors.white.withAlpha(10) : null,
            ),
          ],
        ),
      );
    }
    return groups;
  }

  double _valueForDay(DateTime day) {
    final start = widget.startDate;
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    // Gün tamamen başlamadan önce
    if (dayEnd.isBefore(start)) return 0;

    // Sobriety bu günde başladı
    final effectiveStart = start.isAfter(dayStart) ? start : dayStart;
    final effectiveEnd = dayEnd.isAfter(DateTime.now())
        ? DateTime.now()
        : dayEnd;

    if (effectiveEnd.isBefore(effectiveStart)) return 0;

    final hours =
        effectiveEnd.difference(effectiveStart).inMinutes / 60.0;

    if (_showMoney) {
      return hours / 24.0 * widget.costPerDay;
    }
    return hours;
  }

  double _maxY(List<BarChartGroupData> bars) {
    final max = bars.fold<double>(
      0,
      (prev, g) => g.barRods.first.toY > prev ? g.barRods.first.toY : prev,
    );
    if (max == 0) return _showMoney ? 10 : 24;
    return (max * 1.3).ceilToDouble();
  }

  Widget _bottomTitle(int index, int total) {
    final count = _period == ChartPeriod.week ? 7 : 30;
    final daysAgo = count - 1 - index;
    final day = DateTime.now().subtract(Duration(days: daysAgo));

    String label;
    if (_period == ChartPeriod.week) {
      const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
      label = days[day.weekday - 1];
    } else {
      // Show every 5th day
      label = (index % 5 == 0) ? '${day.day}' : '';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        label,
        style: TextStyle(
          color: daysAgo == 0
              ? AppTheme.gradientStart
              : Colors.white.withAlpha(80),
          fontSize: 10,
          fontWeight:
              daysAgo == 0 ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ─── Toggle chip ──────────────────────────────────────────────────────────────

class _ToggleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ToggleChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.gradientStart.withAlpha(40),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.gradientStart.withAlpha(80)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.gradientStart,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ─── Segmented control ────────────────────────────────────────────────────────

class _SegmentedControl extends StatelessWidget {
  final ChartPeriod selected;
  final ValueChanged<ChartPeriod> onChanged;

  const _SegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCardHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Seg(
            label: '7d',
            active: selected == ChartPeriod.week,
            onTap: () => onChanged(ChartPeriod.week),
          ),
          _Seg(
            label: '30d',
            active: selected == ChartPeriod.month,
            onTap: () => onChanged(ChartPeriod.month),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Seg({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withAlpha(100),
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
