part of 'history_bloc.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  const HistoryLoaded({
    required this.rides,
    required this.hasMore,
  });

  final List<RideModel> rides;
  final bool hasMore;

  @override
  List<Object?> get props => [rides, hasMore];
}

class HistoryFailure extends HistoryState {
  const HistoryFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
