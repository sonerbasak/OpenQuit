import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/habit.dart';
import '../../domain/usecases/add_habit.dart';
import '../../domain/usecases/delete_habit.dart';
import '../../domain/usecases/get_all_habits.dart';
import '../../domain/usecases/toggle_habit_completion.dart';
import '../../domain/usecases/update_habit.dart';

part 'habit_list_state.dart';

@injectable
class HabitListCubit extends Cubit<HabitListState> {
  final GetAllHabits _getAll;
  final AddHabit _add;
  final UpdateHabit _update;
  final DeleteHabit _delete;
  final ToggleHabitCompletion _toggle;

  HabitListCubit(
    this._getAll,
    this._add,
    this._update,
    this._delete,
    this._toggle,
  ) : super(const HabitListInitial());

  // ─── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadHabits() async {
    emit(const HabitListLoading());
    final result = await _getAll(const NoParams());
    result.fold(
      (f) => emit(HabitListError(f.message)),
      (habits) => emit(HabitListLoaded(habits)),
    );
  }

  // ─── Add ───────────────────────────────────────────────────────────────────

  Future<void> addHabit({
    required String name,
    required String iconName,
    String? description,
    required HabitFrequency frequency,
    required List<int> weekDays,
    required String colorHex,
  }) async {
    final params = AddHabitParams(
      id: const Uuid().v4(),
      name: name,
      iconName: iconName,
      description: description,
      frequency: frequency,
      weekDays: weekDays,
      startDate: DateTime.now(),
      colorHex: colorHex,
    );
    final result = await _add(params);
    result.fold(
      (f) => emit(HabitListError(f.message)),
      (_) => loadHabits(),
    );
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  Future<void> updateHabit(Habit habit) async {
    final result = await _update(habit);
    result.fold(
      (f) => emit(HabitListError(f.message)),
      (_) => loadHabits(),
    );
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteHabit(String id) async {
    final result = await _delete(id);
    result.fold(
      (f) => emit(HabitListError(f.message)),
      (_) => loadHabits(),
    );
  }

  // ─── Toggle completion ─────────────────────────────────────────────────────

  Future<void> toggleCompletion(String id, DateTime date) async {
    final result = await _toggle(
      ToggleHabitCompletionParams(id: id, date: date),
    );
    result.fold(
      (f) => emit(HabitListError(f.message)),
      (_) => loadHabits(),
    );
  }
}
