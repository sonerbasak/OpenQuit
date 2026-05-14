import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../cubit/addiction_list/addiction_list_cubit.dart';
import '../widgets/add_addiction_sheet.dart';
import '../widgets/live_addiction_card.dart';
import 'addiction_detail_page.dart';

class AddictionListPage extends StatelessWidget {
  const AddictionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsCubit root'tan geliyor — sadece AddictionListCubit sağlanıyor
    return BlocProvider(
      create: (_) => getIt<AddictionListCubit>()..loadAddictions(),
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
          // ── Ambient background blobs ─────────────────────────────────────
          const _AmbientBlobs(),

          // ── Content ──────────────────────────────────────────────────────
          SafeArea(
            // bottom: false — FAB Positioned ile manuel yönetiliyor
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: BlocConsumer<AddictionListCubit, AddictionListState>(
                    listener: (context, state) {
                      if (state is AddictionListError) {
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
                      AddictionListInitial() ||
                      AddictionListLoading() =>
                        const _LoadingView(),
                      AddictionListError() =>
                        _ErrorView(message: state.message),
                      AddictionListLoaded() when state.addictions.isEmpty =>
                        const _EmptyView(),
                      AddictionListLoaded() => ListView.builder(
                          padding: EdgeInsets.only(
                            top: 8,
                            // FAB yüksekliği (58) + nav bar + boşluk
                            bottom: MediaQuery.of(context).viewPadding.bottom + 90,
                          ),
                          itemCount: state.addictions.length,
                          itemBuilder: (context, i) {
                            final a = state.addictions[i];
                            return LiveAddictionCard(
                              addiction: a,
                              onTap: () => Navigator.push(
                                context,
                                _fadeRoute(
                                  // AddictionListCubit'i yeni route'a taşı
                                  // ki relapse sonrası liste güncellensin
                                  BlocProvider.value(
                                    value: context.read<AddictionListCubit>(),
                                    child: AddictionDetailPage(addictionId: a.id),
                                  ),
                                ),
                              ),
                              onDelete: () => context
                                  .read<AddictionListCubit>()
                                  .deleteAddiction(a.id),
                            );
                          },
                        ),
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── FAB ──────────────────────────────────────────────────────────
          Positioned(
            // viewPadding.bottom = gesture nav bar yüksekliği (0 ise klasik buton bar)
            bottom: MediaQuery.of(context).viewPadding.bottom + 16,
            left: 24,
            right: 24,
            child: _GradientFab(
              onTap: () => AddAddictionSheet.show(context),
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
        children: [
          Expanded(
            child: ShaderMask(
              shaderCallback: (b) =>
                  AppTheme.primaryGradient.createShader(b),
              child: const Text(
                'OpenQuit',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
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

  PageRoute<void> _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );
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
          left: -60,
          child: _Blob(
            size: 280,
            color: AppTheme.gradientStart.withAlpha(40),
          ),
        ),
        Positioned(
          top: 200,
          right: -80,
          child: _Blob(
            size: 220,
            color: AppTheme.gradientEnd.withAlpha(25),
          ),
        ),
      ],
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Icon(icon, color: Colors.white.withAlpha(180), size: 20),
          ),
        ),
      ),
    );
  }
}

// ─── Gradient FAB ─────────────────────────────────────────────────────────────

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
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gradientStart.withAlpha(100),
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
              'Track new addiction',
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
        valueColor: AlwaysStoppedAnimation(AppTheme.gradientStart),
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
              shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
              child: const Icon(
                Icons.self_improvement_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
            const Gap(20),
            const Text(
              'Nothing tracked yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Gap(8),
            Text(
              'Tap the button below to start\ntracking your first addiction.',
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
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Color(0xFFFF4D6D),
            ),
            const Gap(16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withAlpha(180)),
            ),
            const Gap(16),
            FilledButton.icon(
              onPressed: () =>
                  context.read<AddictionListCubit>().loadAddictions(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.gradientStart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
