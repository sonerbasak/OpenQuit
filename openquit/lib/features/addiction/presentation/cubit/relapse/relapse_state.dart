part of 'relapse_cubit.dart';

class RelapseState extends Equatable {
  final List<Relapse> relapses;
  const RelapseState(this.relapses);

  @override
  List<Object?> get props => [relapses];
}
