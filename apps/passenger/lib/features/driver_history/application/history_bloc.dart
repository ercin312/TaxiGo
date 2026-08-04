import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({required DriverRepository driverRepository})
      : _driverRepository = driverRepository,
        super(const HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryLoadMore>(_onLoadMore);
  }

  final DriverRepository _driverRepository;
  int _currentPage = 1;

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    _currentPage = 1;

    final result = await _driverRepository.getRideHistory(page: 1);

    result.fold(
      (message) => emit(HistoryFailure(message)),
      (rides) => emit(HistoryLoaded(
        rides: rides,
        hasMore: rides.length >= 15,
      )),
    );
  }

  Future<void> _onLoadMore(
    HistoryLoadMore event,
    Emitter<HistoryState> emit,
  ) async {
    final current = state;
    if (current is! HistoryLoaded || !current.hasMore) return;

    _currentPage++;
    final result =
        await _driverRepository.getRideHistory(page: _currentPage);

    result.fold(
      (message) => emit(HistoryFailure(message)),
      (rides) => emit(HistoryLoaded(
        rides: [...current.rides, ...rides],
        hasMore: rides.length >= 15,
      )),
    );
  }
}
