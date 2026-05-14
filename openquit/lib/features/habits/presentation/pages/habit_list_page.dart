import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/habit.dart';
import '../cubit/habit_list_cubit.dart';
import '../widgets/add_habit_sheet.dart';
import '../widgets/habit_card.dart';

class HabitListPage extends StatelessWidget {
  const HabitListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HabitListCubit>()..loadHabits(),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Ambient blobs ────────────────────────────────────────────────
          const _AmbientBlobs(),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: BlocConsumer<HabitListCubit, HabitListState>(
                    listener: (context, state) {
                      if (state is HabitListError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: const Color(0xFFFF4D6D),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, state) => switch (state) {
                      HabitListInitial() ||
                      HabitListLoading() =>
                        const _LoadingView(),
                      HabitListError() =>
                        _ErrorView(message: state.message),
                      HabitListLoaded() when state.habits.isEmpty =>
                        const _EmptyView(),
                      HabitListLoaded() =>
                        _HabitListView(habits: state.habits),
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── FAB ──────────────────────────────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).viewPadding.bottom + 16,
            left: 24,
            right: 24,
            child: _GradientFab(
              onTap: () => AddHabitSheet.show(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (b) =>
                      AppTheme.greenGradient.createShader(b),
                  child: const Text(
                    'Habits',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const Gap(4),
                BlocBuilder<HabitListCubit, HabitListState>(
                  builder: (context, state) {
                    if (state is! HabitListLoaded) {
                      return const SizedBox.shrink();
                    }
                    final total =
                        state.habits.where((h) => h.isScheduledToday).length;
                    final done = state.habits
                        .where(
                            (h) => h.isScheduledToday && h.isCompletedToday)
                        .length;
                    return Text(
                      total == 0
                          ? 'No habits scheduled today'
                          : '$done / $total completed today',
                      style: TextStyle(
                        color: Colors.white.withAlpha(120),
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _GlassButton(
            icon: Icons.settings_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<SettingsCubit>(),
                  child: const SettingsPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Habit list view ──────────────────────────────────────────────────────────

class _HabitListView extends StatelessWidget {
  final List<Habit> habits;
  const _HabitListView({required this.habits});

  @override
  Widget build(BuildContext context) {
    // Split: today's habits first, then the rest
    final today = habits.where((h) => h.isScheduledToday).toList();
    final other = habits.where((h) => !h.isScheduledToday).toList();

    return ListView(
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).viewPadding.bottom + 90,
      ),
      children: [
        if (today.isNotEmpty) ...[
          _SectionHeader(
            title: "Today's Habits",
            count: today.length,
          ),
          ...today.map((h) => HabitCard(habit: h)),
        ],
        if (other.isNotEmpty) ...[
          _SectionHeader(
            title: 'Not Scheduled Today',
            count: other.length,
          ),
          ...other.map((h) => HabitCard(habit: h)),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withAlpha(100),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const Gap(8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: Colors.white.withAlpha(120),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ambient blobs ────────────────────────────────────────────────────────────

class _AmbientBlobs extends StatelessWidget {
  const _AmbientBlobs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: _Blob(
            size: 260,
            color: const Color(0xFF11998E).withAlpha(35),
          ),
        ),
        Positioned(
          top: 220,
          left: -80,
          child: _Blob(
            size: 200,
            color: const Color(0xFF38EF7D).withAlpha(20),
          ),
        ),
      ],
    );
  }
}

// ─── Glass button ─────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Icon(icon, color: Colors.white.withAlpha(200), size: 20),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────

class _GradientFab extends StatelessWidget {
  final VoidCallback onTap;
  const _GradientFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: AppTheme.greenGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF11998E).withAlpha(100),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Add new habit',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── States ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Color(0xFF11998E)),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (b) =>
                  AppTheme.greenGradient.createShader(b),
              child: const Icon(
                Icons.checklist_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
            const Gap(20),
            const Text(
              'No habits yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Gap(8),
            Text(
              'Tap the button below to build\nyour first daily habit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withAlpha(120),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: Color(0xFFFF4D6D)),
            const Gap(16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withAlpha(180)),
            ),
            const Gap(16),
            FilledButton.icon(
              onPressed: () =>
                  context.read<HabitListCubit>().loadHabits(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF11998E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
