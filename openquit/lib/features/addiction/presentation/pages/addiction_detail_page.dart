import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/milestones/milestone.dart';
import '../../../../core/milestones/milestone_tracker.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/entities/addiction_stats.dart';
import '../cubit/addiction_stats/addiction_stats_cubit.dart';
import '../cubit/relapse/relapse_cubit.dart';
import '../widgets/milestone_celebration.dart';
import '../widgets/relapse_sheet.dart';
import '../widgets/sobriety_calendar.dart';
import '../widgets/sobriety_chart.dart';
import '../widgets/sobriety_ring.dart';
import '../widgets/stat_card.dart';

class AddictionDetailPage extends StatelessWidget {
  final String addictionId;

  const AddictionDetailPage({super.key, required this.addictionId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<AddictionStatsCubit>()..loadStats(addictionId),
        ),
        // SettingsCubit root'tan geliyor — tekrar sağlamaya gerek yok
        BlocProvider(
          create: (_) =>
              getIt<RelapseCubit>()..loadRelapses(addictionId),
        ),
      ],
      child: _DetailView(addictionId: addictionId),
    );
  }
}

// ─── Stateful view — timer ────────────────────────────────────────────────────

class _DetailView extends StatefulWidget {
  final String addictionId;
  const _DetailView({required this.addictionId});

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        context.read<AddictionStatsCubit>().loadStats(widget.addictionId);
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _checkMilestone(AddictionStats stats, bool notifEnabled) {
    final reached = Milestone.justReached(stats.sobrietyDuration);
    if (reached == null) return;

    final tracker = getIt<MilestoneTracker>();

    // Kalıcı olarak kutlandı mı? (uygulama restart'ına dayanıklı)
    if (tracker.wasNotified(stats.addictionId, reached.id)) return;

    // Hemen işaretle — çift tetiklenmeyi önle
    tracker.markNotified(stats.addictionId, reached.id);

    // In-app kutlama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      MilestoneCelebration.show(
        context,
        milestone: reached,
        addictionName: stats.addictionName,
      );
    });

    // Bildirim (ayar açıksa)
    if (notifEnabled) {
      getIt<NotificationService>().showMilestone(
        milestone: reached,
        addictionName: stats.addictionName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      extendBodyBehindAppBar: true,
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return BlocConsumer<AddictionStatsCubit, AddictionStatsState>(
            listener: (context, state) {
              if (state is AddictionStatsLoaded) {
                _checkMilestone(
                  state.stats,
                  settingsState.settings.milestoneNotificationsEnabled,
                );
              }
            },
            builder: (context, state) => switch (state) {
              AddictionStatsInitial() || AddictionStatsLoading() => const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(AppTheme.gradientStart),
                  ),
                ),
              AddictionStatsError() =>
                _ErrorBody(message: state.message),
              AddictionStatsLoaded() => _LoadedBody(
                  stats: state.stats,
                  currencySymbol: settingsState.settings.currencySymbol,
                ),
            },
          );
        },
      ),
    );
  }
}

// ─── Loaded body ──────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  final AddictionStats stats;
  final String currencySymbol;

  const _LoadedBody({required this.stats, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final fd = DurationFormatter.breakdown(stats.sobrietyDuration);

    return Stack(
      children: [
        _blob(top: -60, right: -60, color: AppTheme.gradientMid, size: 260),
        _blob(bottom: 100, left: -80, color: AppTheme.gradientEnd, size: 200),

        CustomScrollView(
          slivers: [
            // ── App bar ────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.transparent,
              pinned: true,
              leading: _backButton(context),
              title: Text(
                stats.addictionName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              centerTitle: true,
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                // Navigation bar yüksekliği + ekstra boşluk
                MediaQuery.of(context).viewPadding.bottom + 40,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Ring ────────────────────────────────────────────────
                  Center(
                    child: SobrietyRing(
                      progress: stats.dailyProgress,
                      sobrietyDuration: stats.sobrietyDuration,
                    ),
                  ),
                  const Gap(10),
                  Center(child: _FullBreakdown(fd: fd)),
                  const Gap(20),

                  // ── Relapse button ───────────────────────────────────────
                  _RelapseButton(stats: stats),
                  const Gap(28),

                  // ── Stat cards ───────────────────────────────────────────
                  _sectionLabel('YOUR SAVINGS'),
                  const Gap(12),
                  StatCard(
                    icon: Icons.attach_money_rounded,
                    label: 'Money saved',
                    value: DurationFormatter.formatMoney(
                      stats.moneySaved,
                      symbol: currencySymbol,
                    ),
                    gradient: AppTheme.greenGradient,
                  ),
                  const Gap(10),
                  StatCard(
                    icon: Icons.hourglass_bottom_rounded,
                    label: 'Time saved',
                    value: DurationFormatter.toCompactString(stats.timeSaved),
                    gradient: AppTheme.blueGradient,
                  ),
                  const Gap(10),
                  StatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Days clean',
                    value:
                        '${stats.sobrietyDuration.inDays} ${stats.sobrietyDuration.inDays == 1 ? 'day' : 'days'}',
                    gradient: AppTheme.orangeGradient,
                  ),
                  const Gap(10),
                  StatCard(
                    icon: Icons.timer_outlined,
                    label: 'Total hours clean',
                    value: '${stats.sobrietyDuration.inHours}h',
                    gradient: AppTheme.primaryGradient,
                  ),
                  const Gap(28),

                  // ── Chart ────────────────────────────────────────────────
                  _sectionLabel('PROGRESS'),
                  const Gap(12),
                  SobrietyChart(
                    startDate: stats.startDate,
                    currencySymbol: currencySymbol,
                    costPerDay: stats.costPerDay,
                  ),
                  const Gap(28),

                  // ── Calendar ─────────────────────────────────────────────
                  BlocBuilder<RelapseCubit, RelapseState>(
                    builder: (context, rs) => SobrietyCalendar(
                      startDate: stats.startDate,
                      relapses: rs.relapses,
                    ),
                  ),
                  const Gap(28),

                  // ── Milestones ───────────────────────────────────────────
                  MilestoneProgressList(sobriety: stats.sobrietyDuration),

                  // ── Relapse history ──────────────────────────────────────
                  BlocBuilder<RelapseCubit, RelapseState>(
                    builder: (context, rs) {
                      if (rs.relapses.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Gap(28),
                          _sectionLabel('RELAPSE HISTORY'),
                          const Gap(12),
                          _RelapseHistory(relapses: rs.relapses),
                        ],
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: Colors.white.withAlpha(80),
        ),
      );

  Widget _backButton(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(20)),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
    required double size,
  }) =>
      Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(30),
            ),
          ),
        ),
      );
}

// ─── Relapse button ───────────────────────────────────────────────────────────

class _RelapseButton extends StatelessWidget {
  final AddictionStats stats;

  const _RelapseButton({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => RelapseSheet.show(
        context,
        addictionId: stats.addictionId,
        addictionName: stats.addictionName,
        previousSobriety: stats.sobrietyDuration,
        // RelapseCubit bu widget'ın BlocProvider ağacında mevcut
        relapseCubit: context.read<RelapseCubit>(),
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFFF4D6D).withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFFF4D6D).withAlpha(60),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFFFF4D6D).withAlpha(200),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'I Relapsed — Reset Timer',
              style: TextStyle(
                color: const Color(0xFFFF4D6D).withAlpha(220),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Relapse history ──────────────────────────────────────────────────────────

class _RelapseHistory extends StatelessWidget {
  final List relapses;

  const _RelapseHistory({required this.relapses});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < relapses.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Colors.white12),
            _RelapseRow(relapse: relapses[i]),
          ],
        ],
      ),
    );
  }
}

class _RelapseRow extends StatelessWidget {
  final dynamic relapse;

  const _RelapseRow({required this.relapse});

  @override
  Widget build(BuildContext context) {
    final dt = relapse.occurredAt as DateTime;
    final prev = relapse.previousSobriety as Duration;
    final dateStr =
        '${dt.year}-${_p(dt.month)}-${_p(dt.day)}  ${_p(dt.hour)}:${_p(dt.minute)}';
    final prevStr = DurationFormatter.toCompactString(prev);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4D6D).withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFFFF4D6D),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'After $prevStr clean',
                  style: TextStyle(
                    color: Colors.white.withAlpha(100),
                    fontSize: 12,
                  ),
                ),
                if (relapse.note != null &&
                    (relapse.note as String).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '"${relapse.note}"',
                      style: TextStyle(
                        color: Colors.white.withAlpha(140),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _p(int v) => v.toString().padLeft(2, '0');
}

// ─── Breakdown chips ──────────────────────────────────────────────────────────

class _FullBreakdown extends StatelessWidget {
  final FormattedDuration fd;
  const _FullBreakdown({required this.fd});

  @override
  Widget build(BuildContext context) {
    final units = <(int, String)>[
      if (fd.years > 0) (fd.years, 'yr'),
      if (fd.months > 0) (fd.months, 'mo'),
      if (fd.days > 0) (fd.days, 'd'),
      (fd.hours, 'h'),
      (fd.minutes, 'm'),
      (fd.seconds, 's'),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: units.map((u) => _Chip(value: u.$1, unit: u.$2)).toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  final int value;
  final String unit;
  const _Chip({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(18)),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              TextSpan(
                text: unit,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withAlpha(120),
                ),
              ),
            ],
          ),
        ),
      );
}

// ─── Error ────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 56, color: Color(0xFFFF4D6D)),
              const Gap(16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withAlpha(180))),
              const Gap(16),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go back'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.gradientStart),
              ),
            ],
          ),
        ),
      );
}
