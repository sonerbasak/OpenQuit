import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/notifications/notification_service.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/currency.dart';
import '../cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsCubit root BlocProvider'dan geliyor
    return const _SettingsView();
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final s = state.settings;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                ),
                title: const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                centerTitle: true,
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  MediaQuery.of(context).viewPadding.bottom + 40,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Currency ───────────────────────────────────────────
                    _SectionLabel('CURRENCY'),
                    const Gap(10),
                    _GlassCard(
                      child: ListTile(
                        leading:
                            _GradientIcon(Icons.attach_money_rounded),
                        title: const Text(
                          'Currency',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${s.currencyCode} — ${s.currencySymbol}',
                          style: TextStyle(
                            color: Colors.white.withAlpha(120),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withAlpha(80),
                        ),
                        onTap: () => _pickCurrency(context),
                      ),
                    ),
                    const Gap(24),

                    // ── Notifications ──────────────────────────────────────
                    _SectionLabel('NOTIFICATIONS'),
                    const Gap(10),
                    _GlassCard(
                      child: Column(
                        children: [
                          // Daily motivation toggle
                          SwitchListTile(
                            secondary: _GradientIcon(
                              Icons.wb_sunny_rounded,
                              gradient: AppTheme.orangeGradient,
                            ),
                            title: const Text(
                              'Daily Motivation',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Get a motivational quote every day',
                              style: TextStyle(
                                color: Colors.white.withAlpha(120),
                                fontSize: 12,
                              ),
                            ),
                            value: s.dailyMotivationEnabled,
                            activeThumbColor: AppTheme.gradientStart,
                            onChanged: (v) =>
                                _toggleDailyMotivation(context, v, s),
                          ),

                          if (s.dailyMotivationEnabled) ...[
                            const Divider(
                                color: Colors.white12, height: 1),
                            ListTile(
                              leading: _GradientIcon(
                                Icons.access_time_rounded,
                                gradient: AppTheme.blueGradient,
                              ),
                              title: const Text(
                                'Notification Time',
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '${s.notificationHour.toString().padLeft(2, '0')}:'
                                '${s.notificationMinute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(120),
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.white.withAlpha(80),
                              ),
                              onTap: () => _pickTime(
                                context,
                                s.notificationHour,
                                s.notificationMinute,
                              ),
                            ),
                          ],

                          const Divider(color: Colors.white12, height: 1),

                          // Milestone toggle
                          SwitchListTile(
                            secondary: _GradientIcon(
                              Icons.emoji_events_rounded,
                              gradient: AppTheme.greenGradient,
                            ),
                            title: const Text(
                              'Milestone Celebrations',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Notify when you hit a milestone',
                              style: TextStyle(
                                color: Colors.white.withAlpha(120),
                                fontSize: 12,
                              ),
                            ),
                            value: s.milestoneNotificationsEnabled,
                            activeThumbColor: AppTheme.gradientStart,
                            onChanged: (v) =>
                                _toggleMilestone(context, v),
                          ),

                          const Divider(color: Colors.white12, height: 1),

                          // Test notification button
                          ListTile(
                            leading: _GradientIcon(
                              Icons.notifications_active_rounded,
                              gradient: AppTheme.primaryGradient,
                            ),
                            title: const Text(
                              'Send Test Notification',
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Verify notifications are working',
                              style: TextStyle(
                                color: Colors.white.withAlpha(120),
                                fontSize: 12,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white.withAlpha(80),
                            ),
                            onTap: () => _sendTest(context),
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),

                    // ── About ──────────────────────────────────────────────
                    _SectionLabel('ABOUT'),
                    const Gap(10),
                    _GlassCard(
                      child: Column(
                        children: [
                          _InfoTile(
                            icon: Icons.info_outline_rounded,
                            label: 'Version',
                            value: '1.0.0',
                          ),
                          const Divider(color: Colors.white12, height: 1),
                          _InfoTile(
                            icon: Icons.lock_outline_rounded,
                            label: 'Privacy',
                            value: 'Local only — no cloud',
                          ),
                          const Divider(color: Colors.white12, height: 1),
                          _InfoTile(
                            icon: Icons.code_rounded,
                            label: 'License',
                            value: 'MIT Open Source',
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── Handlers ─────────────────────────────────────────────────────────────

  Future<void> _toggleDailyMotivation(
    BuildContext context,
    bool enable,
    dynamic s,
  ) async {
    final notif = getIt<NotificationService>();
    final cubit = context.read<SettingsCubit>();

    if (enable) {
      // İzin iste
      final granted = await notif.requestPermission();
      if (!granted) {
        if (context.mounted) {
          _showPermissionDenied(context);
        }
        return;
      }
      await cubit.setDailyMotivation(enabled: true);
      await notif.scheduleDailyMotivation(
        hour: s.notificationHour,
        minute: s.notificationMinute,
      );
      if (context.mounted) {
        _showSnack(
          context,
          '✅ Daily motivation scheduled at '
          '${s.notificationHour.toString().padLeft(2, '0')}:'
          '${s.notificationMinute.toString().padLeft(2, '0')}',
        );
      }
    } else {
      await cubit.setDailyMotivation(enabled: false);
      await notif.cancelDailyMotivation();
    }
  }

  Future<void> _toggleMilestone(BuildContext context, bool enable) async {
    if (enable) {
      final granted =
          await getIt<NotificationService>().requestPermission();
      if (!granted) {
        if (context.mounted) _showPermissionDenied(context);
        return;
      }
    }
    if (context.mounted) {
      await context
          .read<SettingsCubit>()
          .setMilestoneNotifications(enabled: enable);
    }
  }

  Future<void> _sendTest(BuildContext context) async {
    final notif = getIt<NotificationService>();
    final granted = await notif.requestPermission();
    if (!granted) {
      if (context.mounted) _showPermissionDenied(context);
      return;
    }
    await notif.sendTestNotification();
    if (context.mounted) {
      _showSnack(context, '📬 Test notification sent!');
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    int hour,
    int minute,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.gradientStart,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null || !context.mounted) return;

    final cubit = context.read<SettingsCubit>();
    await cubit.setNotificationTime(picked.hour, picked.minute);

    if (!context.mounted) return;
    final s = cubit.state.settings;
    if (s.dailyMotivationEnabled) {
      await getIt<NotificationService>().scheduleDailyMotivation(
        hour: picked.hour,
        minute: picked.minute,
      );
      if (context.mounted) {
        _showSnack(
          context,
          '✅ Rescheduled for '
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}',
        );
      }
    }
  }

  void _pickCurrency(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // Modal yeni bir overlay route — cubit'i açıkça geçmek gerekir
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _CurrencyPicker(),
      ),
    );
  }

  void _showPermissionDenied(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          '⚠️ Notification permission denied. '
          'Enable it in device Settings → Apps → OpenQuit.',
        ),
        backgroundColor: const Color(0xFFFF4D6D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.gradientStart,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// ─── Currency Picker ──────────────────────────────────────────────────────────

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker();

  @override
  Widget build(BuildContext context) {
    final current =
        context.read<SettingsCubit>().state.settings.currencyCode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(12),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Gap(16),
        const Text(
          'Select Currency',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const Gap(12),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: Currency.all.length,
            itemBuilder: (context, i) {
              final c = Currency.all[i];
              final isSelected = c.code == current;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient:
                        isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected
                        ? null
                        : Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      c.symbol,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withAlpha(180),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  c.name,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withAlpha(180),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                subtitle: Text(
                  c.code,
                  style:
                      TextStyle(color: Colors.white.withAlpha(80)),
                ),
                trailing: isSelected
                    ? ShaderMask(
                        shaderCallback: (b) =>
                            AppTheme.primaryGradient.createShader(b),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                      )
                    : null,
                onTap: () {
                  context.read<SettingsCubit>().setCurrency(c);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        const Gap(16),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: Colors.white.withAlpha(80),
        ),
      );
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      );
}

class _GradientIcon extends StatelessWidget {
  final IconData icon;
  final LinearGradient gradient;

  const _GradientIcon(
    this.icon, {
    this.gradient = AppTheme.primaryGradient,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: _GradientIcon(icon),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            color: Colors.white.withAlpha(120),
            fontSize: 13,
          ),
        ),
      );
}
