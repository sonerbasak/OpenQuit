import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/addiction_icons.dart';
import '../../../../../core/utils/duration_formatter.dart';
import '../../domain/entities/addiction.dart';

/// Ana sayfadaki her addiction için canlı sayaç kartı.
///
/// ⚡ Kendi içinde [Timer.periodic] başlatır — sadece widget ağaçta
/// olduğu sürece çalışır. Dispose'da iptal edilir.
/// Hesaplama: [DateTime.now().difference(startDate)] — arka plan işlemi yok.
class LiveAddictionCard extends StatefulWidget {
  final Addiction addiction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const LiveAddictionCard({
    super.key,
    required this.addiction,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<LiveAddictionCard> createState() => _LiveAddictionCardState();
}

class _LiveAddictionCardState extends State<LiveAddictionCard>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  late Duration _sobriety;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _sobriety = _calc();

    // Pulse animation for the live dot
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Tick every second — pure timestamp diff, no battery drain
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _sobriety = _calc());
    });
  }

  Duration _calc() =>
      DateTime.now().difference(widget.addiction.startDate);

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fd = DurationFormatter.breakdown(_sobriety);
    final days = _sobriety.inDays;
    // Daily ring progress (0.0–1.0)
    final progress = (_sobriety.inSeconds % 86400) / 86400.0;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withAlpha(12)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.gradientStart.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top row ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.gradientStart.withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      AddictionIcons.fromName(widget.addiction.iconName),
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + live dot
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.addiction.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (_, __) => Opacity(
                                opacity: _pulseAnim.value,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF38EF7D),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$days ${days == 1 ? 'day' : 'days'} clean',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withAlpha(140),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Delete
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white.withAlpha(80),
                      size: 20,
                    ),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
            ),

            // ── Live timer row ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  // Mini ring
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CustomPaint(
                      painter: _MiniRingPainter(progress: progress),
                      child: Center(
                        child: Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // HH:MM:SS ticker
                  Expanded(
                    child: _TimerDisplay(fd: fd),
                  ),

                  // Arrow
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete?', style: TextStyle(color: Colors.white)),
        content: Text(
          'All progress for "${widget.addiction.name}" will be lost.',
          style: TextStyle(color: Colors.white.withAlpha(180)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withAlpha(180)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D6D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Timer Display ────────────────────────────────────────────────────────────

class _TimerDisplay extends StatelessWidget {
  final FormattedDuration fd;

  const _TimerDisplay({required this.fd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TimeUnit(value: fd.hours, label: 'H'),
        _Colon(),
        _TimeUnit(value: fd.minutes, label: 'M'),
        _Colon(),
        _TimeUnit(value: fd.seconds, label: 'S'),
      ],
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withAlpha(80),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white.withAlpha(60),
        ),
      ),
    );
  }
}

// ─── Mini Ring Painter ────────────────────────────────────────────────────────

class _MiniRingPainter extends CustomPainter {
  final double progress;

  const _MiniRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const stroke = 4.0;
    final radius = (size.width - stroke) / 2;
    const start = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = Colors.white.withAlpha(18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    if (progress > 0) {
      final sweep = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        Paint()
          ..shader = const SweepGradient(
            colors: [AppTheme.gradientStart, AppTheme.gradientEnd],
            startAngle: start,
            endAngle: start + 2 * math.pi,
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) => old.progress != progress;
}
