import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/duration_formatter.dart';

/// Animated gradient ring showing daily sobriety progress.
/// Completes one full rotation every 24 hours.
class SobrietyRing extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final Duration sobrietyDuration;
  final double size;

  const SobrietyRing({
    super.key,
    required this.progress,
    required this.sobrietyDuration,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    final fd = DurationFormatter.breakdown(sobrietyDuration);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow backdrop
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.gradientStart.withAlpha(60),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),

          // Ring painter
          CustomPaint(
            size: Size(size, size),
            painter: _GradientRingPainter(progress: progress),
          ),

          // Glass centre
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: size * 0.68,
                height: size * 0.68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(10),
                  border: Border.all(
                    color: Colors.white.withAlpha(20),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPrimaryValue(fd),
                    const SizedBox(height: 2),
                    _buildSecondaryValue(fd),
                    const SizedBox(height: 6),
                    Text(
                      'CLEAN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryValue(FormattedDuration fd) {
    final (value, unit) = _primaryUnit(fd);
    return ShaderMask(
      shaderCallback: (bounds) =>
          AppTheme.primaryGradient.createShader(bounds),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 3),
            child: Text(
              unit,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryValue(FormattedDuration fd) {
    final secondary = _secondaryLabel(fd);
    if (secondary.isEmpty) return const SizedBox.shrink();
    return Text(
      secondary,
      style: TextStyle(
        fontSize: 13,
        color: Colors.white.withAlpha(120),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  (String, String) _primaryUnit(FormattedDuration fd) {
    if (fd.years > 0) return ('${fd.years}', 'yr');
    if (fd.months > 0) return ('${fd.months}', 'mo');
    if (fd.days > 0) return ('${fd.days}', 'd');
    if (fd.hours > 0) return ('${fd.hours}', 'h');
    if (fd.minutes > 0) return ('${fd.minutes}', 'm');
    return ('${fd.seconds}', 's');
  }

  String _secondaryLabel(FormattedDuration fd) {
    if (fd.years > 0) return '${fd.months}mo ${fd.days}d';
    if (fd.months > 0) return '${fd.days}d ${fd.hours}h';
    if (fd.days > 0) return '${fd.hours}h ${fd.minutes}m ${fd.seconds}s';
    if (fd.hours > 0) return '${fd.minutes}m ${fd.seconds}s';
    if (fd.minutes > 0) return '${fd.seconds}s';
    return '';
  }
}

// ─── Gradient Ring Painter ────────────────────────────────────────────────────

class _GradientRingPainter extends CustomPainter {
  final double progress;

  const _GradientRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 16.0;
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = Colors.white.withAlpha(15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (progress <= 0) return;

    // Gradient arc via shader
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * math.pi * progress;

    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: const [
          AppTheme.gradientStart,
          AppTheme.gradientMid,
          AppTheme.gradientEnd,
        ],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        tileMode: TileMode.clamp,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);

    // Glowing dot at the tip
    final tipAngle = startAngle + sweepAngle;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);

    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeWidth / 2,
      Paint()
        ..color = AppTheme.gradientEnd
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      Offset(tipX, tipY),
      strokeWidth / 2.5,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_GradientRingPainter old) => old.progress != progress;
}
