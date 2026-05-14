import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/addiction.dart';
import '../../../domain/usecases/add_addiction.dart';
import '../../../domain/usecases/delete_addiction.dart';
import '../../../domain/usecases/get_all_addictions.dart';

part 'addiction_list_state.dart';

/// Manages the state of the addiction list screen.
///
/// Responsibilities:
/// - Load all addictions on startup
/// - Add a new addiction and refresh the list
/// - Delete an addiction and refresh the list
///
/// No business logic lives here — all rules are in the use cases.
@injectable
class AddictionListCubit extends Cubit<AddictionListState> {
  final GetAllAddictions _getAll;
  final AddAddiction _add;
  final DeleteAddiction _delete;

  AddictionListCubit(
    this._getAll,
    this._add,
    this._delete,
  ) : super(const AddictionListInitial());

  /// Loads all addictions from local storage.
  Future<void> loadAddictions() async {
    emit(const AddictionListLoading());

    final result = await _getAll(const NoParams());

    result.fold(
      (failure) => emit(AddictionListError(failure.message)),
      (addictions) => emit(AddictionListLoaded(addictions)),
    );
  }

  /// Adds a new addiction and reloads the list.
  Future<void> addAddiction(AddAddictionParams params) async {
    final result = await _add(params);

    result.fold(
      (failure) => emit(AddictionListError(failure.message)),
      (_) => loadAddictions(),
    );
  }

  /// Deletes an addiction by id and reloads the list.
  Future<void> deleteAddiction(String id) async {
    final result = await _delete(DeleteAddictionParams(id: id));

    result.fold(
      (failure) => emit(AddictionListError(failure.message)),
      (_) => loadAddictions(),
    );
  }
}
