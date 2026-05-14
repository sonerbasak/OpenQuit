import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/habit.dart';
import '../cubit/habit_list_cubit.dart';

/// Bottom sheet for creating or editing a habit.
///
/// Pass [existing] to pre-fill fields for editing.
class AddHabitSheet extends StatefulWidget {
  final Habit? existing;

  const AddHabitSheet({super.key, this.existing});

  static Future<void> show(BuildContext context, {Habit? existing}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<HabitListCubit>(),
        child: AddHabitSheet(existing: existing),
      ),
    );
  }

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  late HabitFrequency _frequency;
  late List<int> _weekDays;
  late String _iconName;
  late String _colorHex;

  bool _saving = false;

  // ─── Preset options ───────────────────────────────────────────────────────

  static const _icons = [
    ('self_improvement', Icons.self_improvement_rounded),
    ('fitness_center', Icons.fitness_center_rounded),
    ('menu_book', Icons.menu_book_rounded),
    ('water_drop', Icons.water_drop_rounded),
    ('bedtime', Icons.bedtime_rounded),
    ('directions_run', Icons.directions_run_rounded),
    ('restaurant', Icons.restaurant_rounded),
    ('favorite', Icons.favorite_rounded),
    ('psychology', Icons.psychology_rounded),
    ('music_note', Icons.music_note_rounded),
    ('brush', Icons.brush_rounded),
    ('code', Icons.code_rounded),
  ];

  static const _colors = [
    '7C5CFC', // purple
    'B06EFF', // violet
    'FF6B9D', // pink
    '11998E', // teal
    '38EF7D', // green
    '2193B0', // blue
    '6DD5FA', // sky
    'FF8008', // orange
    'FFC837', // yellow
    'FF4D6D', // red
  ];

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final h = widget.existing;
    _nameCtrl = TextEditingController(text: h?.name ?? '');
    _descCtrl = TextEditingController(text: h?.description ?? '');
    _frequency = h?.frequency ?? HabitFrequency.daily;
    _weekDays = List<int>.from(h?.weekDays ?? []);
    _iconName = h?.iconName ?? 'self_improvement';
    _colorHex = h?.colorHex ?? '7C5CFC';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Color _color(String hex) =>
      Color(int.parse('FF$hex', radix: 16));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // custom modunda en az bir gün seçilmeli
    if (_frequency == HabitFrequency.custom && _weekDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day.')),
      );
      return;
    }

    setState(() => _saving = true);
    final cubit = context.read<HabitListCubit>();

    // weekly = haftada bir, gün seçimi yok → weekDays boş
    final days =
        _frequency == HabitFrequency.custom ? _weekDays : <int>[];

    if (widget.existing != null) {
      await cubit.updateHabit(
        widget.existing!.copyWith(
          name: _nameCtrl.text.trim(),
          iconName: _iconName,
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          frequency: _frequency,
          weekDays: days,
          colorHex: _colorHex,
        ),
      );
    } else {
      await cubit.addHabit(
        name: _nameCtrl.text.trim(),
        iconName: _iconName,
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        frequency: _frequency,
        weekDays: days,
        colorHex: _colorHex,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.existing != null;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withAlpha(230),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottom + 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Handle ──────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(60),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Gap(20),

                  // ── Title ───────────────────────────────────────────────
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppTheme.primaryGradient.createShader(b),
                    child: Text(
                      isEdit ? 'Edit Habit' : 'New Habit',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Gap(24),

                  // ── Name ────────────────────────────────────────────────
                  _label('Name'),
                  const Gap(8),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('e.g. Morning meditation'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const Gap(16),

                  // ── Description ─────────────────────────────────────────
                  _label('Description (optional)'),
                  const Gap(8),
                  TextFormField(
                    controller: _descCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Short note…'),
                    maxLines: 2,
                  ),
                  const Gap(20),

                  // ── Icon picker ─────────────────────────────────────────
                  _label('Icon'),
                  const Gap(10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _icons.map((e) {
                      final selected = _iconName == e.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _iconName = e.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: selected
                                ? _color(_colorHex).withAlpha(60)
                                : Colors.white.withAlpha(10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? _color(_colorHex)
                                  : Colors.white.withAlpha(20),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            e.$2,
                            color: selected
                                ? _color(_colorHex)
                                : Colors.white.withAlpha(120),
                            size: 22,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const Gap(20),

                  // ── Color picker ─────────────────────────────────────────
                  _label('Color'),
                  const Gap(10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _colors.map((hex) {
                      final selected = _colorHex == hex;
                      return GestureDetector(
                        onTap: () => setState(() => _colorHex = hex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _color(hex),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: _color(hex).withAlpha(120),
                                      blurRadius: 8,
                                    )
                                  ]
                                : null,
                          ),
                          child: selected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const Gap(20),

                  // ── Frequency ────────────────────────────────────────────
                  _label('Frequency'),
                  const Gap(10),
                  _FrequencySelector(
                    selected: _frequency,
                    onChanged: (f) => setState(() {
                      _frequency = f;
                      // weekly ve daily'de gün seçimi yok
                      if (f != HabitFrequency.custom) _weekDays = [];
                    }),
                  ),

                  // ── Day picker (sadece custom) ────────────────────────────
                  if (_frequency == HabitFrequency.custom) ...[
                    const Gap(16),
                    _label('Custom days'),
                    const Gap(10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (i) {
                        final day = i + 1; // 1=Mon … 7=Sun
                        final selected = _weekDays.contains(day);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (selected) {
                              _weekDays.remove(day);
                            } else {
                              _weekDays.add(day);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selected
                                  ? _color(_colorHex)
                                  : Colors.white.withAlpha(10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? _color(_colorHex)
                                    : Colors.white.withAlpha(20),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _dayLabels[i],
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : Colors.white.withAlpha(120),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  const Gap(28),

                  // ── Save button ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: _saving
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(
                                  AppTheme.gradientStart),
                            ),
                          )
                        : GestureDetector(
                            onTap: _save,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppTheme.gradientStart.withAlpha(80),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  isEdit ? 'Save Changes' : 'Create Habit',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
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
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          color: Colors.white.withAlpha(160),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withAlpha(60)),
        filled: true,
        fillColor: Colors.white.withAlpha(10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.gradientStart),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}

// ─── Frequency selector ───────────────────────────────────────────────────────

class _FrequencySelector extends StatelessWidget {
  final HabitFrequency selected;
  final ValueChanged<HabitFrequency> onChanged;

  const _FrequencySelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: HabitFrequency.values.map((f) {
        final isSelected = f == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withAlpha(20),
                ),
              ),
              child: Center(
                child: Text(
                  _label(f),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withAlpha(140),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(HabitFrequency f) => switch (f) {
        HabitFrequency.daily => 'Daily',
        HabitFrequency.weekly => 'Weekly',
        HabitFrequency.custom => 'Custom',
      };
}
