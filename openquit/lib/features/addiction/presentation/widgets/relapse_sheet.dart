import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../../core/theme/app_theme.dart';
import '../cubit/relapse/relapse_cubit.dart';

/// Relapse onay ve not sheet'i.
///
/// Sadece [addictionId] ve [previousSobriety] alır.
/// Gerçek addiction verisi cubit içinde DB'den çekilir — veri kaybı olmaz.
class RelapseSheet extends StatefulWidget {
  final String addictionId;
  final String addictionName;
  final Duration previousSobriety;

  const RelapseSheet({
    super.key,
    required this.addictionId,
    required this.addictionName,
    required this.previousSobriety,
  });

  /// Sheet'i göster. [relapseCubit] parent context'ten geçirilir.
  static Future<void> show(
    BuildContext context, {
    required String addictionId,
    required String addictionName,
    required Duration previousSobriety,
    required RelapseCubit relapseCubit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BlocProvider.value(
        value: relapseCubit,
        child: RelapseSheet(
          addictionId: addictionId,
          addictionName: addictionName,
          previousSobriety: previousSobriety,
        ),
      ),
    );
  }

  @override
  State<RelapseSheet> createState() => _RelapseSheetState();
}

class _RelapseSheetState extends State<RelapseSheet> {
  final _noteCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final error = await context.read<RelapseCubit>().recordRelapse(
          addictionId: widget.addictionId,
          previousSobriety: widget.previousSobriety,
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.previousSobriety.inDays;
    final hours = widget.previousSobriety.inHours % 24;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(20),

          // Warning icon
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D6D).withAlpha(20),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF4D6D).withAlpha(80),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFFF4D6D),
                size: 32,
              ),
            ),
          ),
          const Gap(16),

          const Text(
            'Record a Relapse',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Gap(8),

          Text(
            'You\'ve been clean for '
            '${days > 0 ? '$days day${days == 1 ? '' : 's'} ' : ''}'
            '${hours > 0 ? '$hours hour${hours == 1 ? '' : 's'}' : ''}'
            '${days == 0 && hours == 0 ? 'less than an hour' : ''}.'
            '\nThis will reset your timer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const Gap(20),

          // Optional note
          TextField(
            controller: _noteCtrl,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'What triggered it? (optional)',
              hintStyle: TextStyle(color: Colors.white.withAlpha(60)),
              filled: true,
              fillColor: AppTheme.darkCardHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.white.withAlpha(20)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFFF4D6D),
                  width: 1.5,
                ),
              ),
            ),
          ),

          // Error message
          if (_error != null) ...[
            const Gap(10),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFF4D6D),
                fontSize: 13,
              ),
            ),
          ],

          const Gap(20),

          // Confirm button
          GestureDetector(
            onTap: _loading ? null : _confirm,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 54,
              decoration: BoxDecoration(
                color: _loading
                    ? Colors.white.withAlpha(20)
                    : const Color(0xFFFF4D6D),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _loading
                    ? null
                    : [
                        BoxShadow(
                          color: const Color(0xFFFF4D6D).withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Reset & Record Relapse',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const Gap(10),

          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel — I'm still clean",
              style: TextStyle(
                color: Colors.white.withAlpha(120),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
