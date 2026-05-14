import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../../core/milestones/milestone.dart';
import '../../../../../core/theme/app_theme.dart';

/// Milestone geçildiğinde gösterilen kutlama overlay'i.
class MilestoneCelebration extends StatefulWidget {
  final Milestone milestone;
  final String addictionName;

  const MilestoneCelebration({
    super.key,
    required this.milestone,
    required this.addictionName,
  });

  static Future<void> show(
    BuildContext context, {
    required Milestone milestone,
    required String addictionName,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(160),
      builder: (_) => MilestoneCelebration(
        milestone: milestone,
        addictionName: addictionName,
      ),
    );
  }

  @override
  State<MilestoneCelebration> createState() => _MilestoneCelebrationState();
}

class _MilestoneCelebrationState extends State<MilestoneCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.gradientStart.withAlpha(80),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gradientStart.withAlpha(60),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emoji
                Text(
                  widget.milestone.emoji,
                  style: const TextStyle(fontSize: 64),
                ),
                const Gap(12),

                // Milestone label
                ShaderMask(
                  shaderCallback: (b) =>
                      AppTheme.primaryGradient.createShader(b),
                  child: Text(
                    widget.milestone.label,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Gap(4),

                Text(
                  widget.addictionName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(120),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(16),

                // Message
                Text(
                  widget.milestone.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withAlpha(200),
                    height: 1.5,
                  ),
                ),
                const Gap(28),

                // CTA
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gradientStart.withAlpha(80),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Keep going! 🚀',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Milestone progress listesi ───────────────────────────────────────────────

class MilestoneProgressList extends StatelessWidget {
  final Duration sobriety;

  const MilestoneProgressList({super.key, required this.sobriety});

  @override
  Widget build(BuildContext context) {
    final achieved = Milestone.achieved(sobriety);
    final next = Milestone.next(sobriety);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MILESTONES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white.withAlpha(80),
            ),
          ),
          const Gap(16),

          // Next milestone progress
          if (next != null) ...[
            _NextMilestone(sobriety: sobriety, next: next),
            const Gap(16),
          ],

          // Achieved list
          ...Milestone.all.map((m) {
            final done = achieved.contains(m);
            final isNext = m == next;
            return _MilestoneRow(
              milestone: m,
              achieved: done,
              isNext: isNext,
            );
          }),
        ],
      ),
    );
  }
}

class _NextMilestone extends StatelessWidget {
  final Duration sobriety;
  final Milestone next;

  const _NextMilestone({required this.sobriety, required this.next});

  @override
  Widget build(BuildContext context) {
    final progress =
        sobriety.inSeconds / next.threshold.inSeconds;
    final remaining = next.threshold - sobriety;
    final remainingStr = _format(remaining);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.gradientStart.withAlpha(30),
            AppTheme.gradientEnd.withAlpha(15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gradientStart.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(next.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Next: ${next.label}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                remainingStr,
                style: TextStyle(
                  color: AppTheme.gradientStart,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withAlpha(15),
              valueColor: const AlwaysStoppedAnimation(AppTheme.gradientStart),
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m ${d.inSeconds % 60}s';
  }
}

class _MilestoneRow extends StatelessWidget {
  final Milestone milestone;
  final bool achieved;
  final bool isNext;

  const _MilestoneRow({
    required this.milestone,
    required this.achieved,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: achieved ? AppTheme.primaryGradient : null,
              color: achieved ? null : Colors.white.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: achieved
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : Text(
                      milestone.emoji,
                      style: TextStyle(
                        fontSize: 14,
                        color: isNext ? null : Colors.white.withAlpha(40),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              milestone.label,
              style: TextStyle(
                color: achieved
                    ? Colors.white
                    : isNext
                        ? Colors.white.withAlpha(180)
                        : Colors.white.withAlpha(60),
                fontWeight:
                    achieved ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
                decoration:
                    achieved ? null : null,
              ),
            ),
          ),

          if (achieved)
            ShaderMask(
              shaderCallback: (b) =>
                  AppTheme.primaryGradient.createShader(b),
              child: const Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
