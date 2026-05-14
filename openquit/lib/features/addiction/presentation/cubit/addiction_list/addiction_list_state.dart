part of 'addiction_list_cubit.dart';

/// States for the addiction list screen.
sealed class AddictionListState extends Equatable {
  const AddictionListState();

  @override
  List<Object?> get props => [];
}

/// Initial state — nothing loaded yet.
final class AddictionListInitial extends AddictionListState {
  const AddictionListInitial();
}

/// Data is being fetched from local storage.
final class AddictionListLoading extends AddictionListState {
  const AddictionListLoading();
}

/// Addictions loaded successfully.
final class AddictionListLoaded extends AddictionListState {
  final List<Addiction> addictions;

  const AddictionListLoaded(this.addictions);

  @override
  List<Object?> get props => [addictions];
}

/// An error occurred.
final class AddictionListError extends AddictionListState {
  final String message;

  const AddictionListError(this.message);

  @override
  List<Object?> get props => [message];
}
