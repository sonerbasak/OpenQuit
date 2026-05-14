import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../core/utils/addiction_icons.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../domain/usecases/add_addiction.dart';
import '../cubit/addiction_list/addiction_list_cubit.dart';

class AddAddictionSheet extends StatefulWidget {
  const AddAddictionSheet({super.key});

  static Future<void> show(BuildContext context) {
    final listCubit = context.read<AddictionListCubit>();
    final settingsCubit = context.read<SettingsCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: listCubit),
          BlocProvider.value(value: settingsCubit),
        ],
        child: const AddAddictionSheet(),
      ),
    );
  }

  @override
  State<AddAddictionSheet> createState() => _AddAddictionSheetState();
}

class _AddAddictionSheetState extends State<AddAddictionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _costCtrl = TextEditingController(text: '0');
  final _minutesCtrl = TextEditingController(text: '0');

  String _selectedIcon = 'default';
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _costCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  DateTime get _combinedDateTime => DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    await context.read<AddictionListCubit>().addAddiction(
          AddAddictionParams(
            id: const Uuid().v4(),
            name: _nameCtrl.text.trim(),
            iconName: _selectedIcon,
            startDate: _combinedDateTime,
            costPerDay: double.tryParse(_costCtrl.text) ?? 0,
            minutesWastedPerDay: int.tryParse(_minutesCtrl.text) ?? 0,
          ),
        );

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.dark(primary: AppTheme.gradientStart),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.dark(primary: AppTheme.gradientStart),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_startDate.year}-${_pad(_startDate.month)}-${_pad(_startDate.day)}';
    final timeStr =
        '${_pad(_startTime.hour)}:${_pad(_startTime.minute)}';

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
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

              ShaderMask(
                shaderCallback: (b) =>
                    AppTheme.primaryGradient.createShader(b),
                child: const Text(
                  'Track a new addiction',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Gap(20),

              // Name
              _field(
                controller: _nameCtrl,
                label: 'Addiction name',
                hint: 'e.g. Smoking, Alcohol…',
                icon: Icons.label_outline_rounded,
                caps: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name is required'
                    : null,
              ),
              const Gap(14),

              // Icon picker
              _IconPicker(
                selected: _selectedIcon,
                onChanged: (v) => setState(() => _selectedIcon = v),
              ),
              const Gap(14),

              // ── Date + Time row ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _DateTimeTile(
                      icon: Icons.calendar_today_rounded,
                      label: 'Quit date',
                      value: dateStr,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateTimeTile(
                      icon: Icons.access_time_rounded,
                      label: 'Quit time',
                      value: timeStr,
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const Gap(14),

              // Cost
              _field(
                controller: _costCtrl,
                label: 'Cost per day (${context.read<SettingsCubit>().state.settings.currencySymbol})',
                icon: Icons.attach_money_rounded,
                keyboard:
                    const TextInputType.numberWithOptions(decimal: true),
                formatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d*')),
                ],
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return (n == null || n < 0)
                      ? 'Enter a valid amount'
                      : null;
                },
              ),
              const Gap(14),

              // Minutes
              _field(
                controller: _minutesCtrl,
                label: 'Minutes wasted per day',
                icon: Icons.timer_outlined,
                keyboard: TextInputType.number,
                formatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return (n == null || n < 0)
                      ? 'Enter a valid number'
                      : null;
                },
              ),
              const Gap(24),

              // Submit
              _GradientButton(
                loading: _submitting,
                label: 'Start tracking',
                icon: Icons.check_rounded,
                onTap: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextCapitalization caps = TextCapitalization.none,
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        textCapitalization: caps,
        keyboardType: keyboard,
        inputFormatters: formatters,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        validator: validator,
      );

  String _pad(int v) => v.toString().padLeft(2, '0');
}

// ─── Date/Time tile ───────────────────────────────────────────────────────────

class _DateTimeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimeTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkCardHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.gradientStart),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withAlpha(100),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
}

// ─── Gradient button ──────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final bool loading;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _GradientButton({
    required this.loading,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: loading ? null : AppTheme.primaryGradient,
          color: loading ? Colors.white.withAlpha(20) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: loading
              ? null
              : [
                  BoxShadow(
                    color: AppTheme.gradientStart.withAlpha(80),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Icon Picker ──────────────────────────────────────────────────────────────

class _IconPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _IconPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withAlpha(120),
          ),
        ),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AddictionIcons.all.map((entry) {
            final isSelected = entry.key == selected;
            return GestureDetector(
              onTap: () => onChanged(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : AppTheme.darkCardHigh,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withAlpha(20),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.gradientStart.withAlpha(80),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  entry.value,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withAlpha(120),
                  size: 22,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
