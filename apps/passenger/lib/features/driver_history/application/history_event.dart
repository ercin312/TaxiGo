part of 'history_bloc.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class HistoryLoadRequested extends HistoryEvent {
  const HistoryLoadRequested();
}

class HistoryLoadMore extends HistoryEvent {
  const HistoryLoadMore();
}
