import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

abstract class BiddingEvent extends Equatable {
  const BiddingEvent();

  @override
  List<Object?> get props => [];
}

class BiddingStarted extends BiddingEvent {
  const BiddingStarted(this.ride);

  final RideModel ride;

  @override
  List<Object?> get props => [ride];
}

class BiddingPollRequested extends BiddingEvent {
  const BiddingPollRequested();
}

class BiddingOfferAdjusted extends BiddingEvent {
  const BiddingOfferAdjusted(this.delta);

  final double delta;

  @override
  List<Object?> get props => [delta];
}

class BiddingOfferUpdateRequested extends BiddingEvent {
  const BiddingOfferUpdateRequested();
}

class BiddingAcceptBid extends BiddingEvent {
  const BiddingAcceptBid(this.bidId);

  final int bidId;

  @override
  List<Object?> get props => [bidId];
}

class BiddingRejectBid extends BiddingEvent {
  const BiddingRejectBid(this.bidId);

  final int bidId;

  @override
  List<Object?> get props => [bidId];
}

class BiddingCancelRequested extends BiddingEvent {
  const BiddingCancelRequested();
}

enum BiddingStatus { loading, waiting, assigned, cancelled, failure }

class BiddingState extends Equatable {
  const BiddingState({
    this.status = BiddingStatus.loading,
    this.ride,
    this.bids = const [],
    this.currentOffer,
    this.minimumFare,
    this.errorMessage,
    this.assignedRide,
  });

  final BiddingStatus status;
  final RideModel? ride;
  final List<RideBidModel> bids;
  final double? currentOffer;
  final double? minimumFare;
  final String? errorMessage;
  final RideModel? assignedRide;

  BiddingState copyWith({
    BiddingStatus? status,
    RideModel? ride,
    List<RideBidModel>? bids,
    double? currentOffer,
    double? minimumFare,
    String? errorMessage,
    RideModel? assignedRide,
    bool clearError = false,
  }) {
    return BiddingState(
      status: status ?? this.status,
      ride: ride ?? this.ride,
      bids: bids ?? this.bids,
      currentOffer: currentOffer ?? this.currentOffer,
      minimumFare: minimumFare ?? this.minimumFare,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      assignedRide: assignedRide ?? this.assignedRide,
    );
  }

  @override
  List<Object?> get props => [
        status,
        ride,
        bids,
        currentOffer,
        minimumFare,
        errorMessage,
        assignedRide,
      ];
}

class BiddingBloc extends Bloc<BiddingEvent, BiddingState> {
  BiddingBloc({required RideRepository rideRepository})
      : _rideRepository = rideRepository,
        super(const BiddingState()) {
    on<BiddingStarted>(_onStarted);
    on<BiddingPollRequested>(_onPoll);
    on<BiddingOfferAdjusted>(_onOfferAdjusted);
    on<BiddingOfferUpdateRequested>(_onOfferUpdate);
    on<BiddingAcceptBid>(_onAcceptBid);
    on<BiddingRejectBid>(_onRejectBid);
    on<BiddingCancelRequested>(_onCancel);
  }

  final RideRepository _rideRepository;
  Timer? _pollTimer;

  static const double fareStep = 10;

  Future<void> _onStarted(
    BiddingStarted event,
    Emitter<BiddingState> emit,
  ) async {
    final ride = event.ride;
    emit(BiddingState(
      status: BiddingStatus.waiting,
      ride: ride,
      currentOffer: ride.offeredFare ?? ride.estimatedFare,
      minimumFare: ride.minimumFare ?? ride.estimatedFare,
    ));
    _startPolling();
    add(const BiddingPollRequested());
  }

  Future<void> _onPoll(
    BiddingPollRequested event,
    Emitter<BiddingState> emit,
  ) async {
    final ride = state.ride;
    if (ride == null) return;

    final rideResult = await _rideRepository.getRide(ride.id);
    await rideResult.fold(
      (message) async => emit(state.copyWith(errorMessage: message)),
      (updatedRide) async {
        if (updatedRide.driverId != null &&
            updatedRide.status != RideStatus.pending) {
          _stopPolling();
          emit(state.copyWith(
            status: BiddingStatus.assigned,
            ride: updatedRide,
            assignedRide: updatedRide,
          ));
          return;
        }

        if (updatedRide.status.isTerminal) {
          _stopPolling();
          emit(state.copyWith(ride: updatedRide));
        }
      },
    );

    final bidsResult = await _rideRepository.getRideBids(ride.id);
    bidsResult.fold(
      (message) => emit(state.copyWith(errorMessage: message)),
      (bids) => emit(state.copyWith(
        bids: bids,
        status: BiddingStatus.waiting,
        clearError: true,
      )),
    );
  }

  void _onOfferAdjusted(
    BiddingOfferAdjusted event,
    Emitter<BiddingState> emit,
  ) {
    final minimum = state.minimumFare ?? 0;
    final next = (state.currentOffer ?? minimum) + event.delta;
    if (next < minimum) return;
    emit(state.copyWith(currentOffer: next));
  }

  Future<void> _onOfferUpdate(
    BiddingOfferUpdateRequested event,
    Emitter<BiddingState> emit,
  ) async {
    final ride = state.ride;
    final offer = state.currentOffer;
    if (ride == null || offer == null) return;

    emit(state.copyWith(status: BiddingStatus.loading, clearError: true));
    final result = await _rideRepository.updateOfferedFare(
      ride.id,
      offeredFare: offer,
    );

    result.fold(
      (message) => emit(state.copyWith(
        status: BiddingStatus.waiting,
        errorMessage: message,
      )),
      (updatedRide) => emit(state.copyWith(
        status: BiddingStatus.waiting,
        ride: updatedRide,
        currentOffer: updatedRide.offeredFare ?? offer,
      )),
    );
  }

  Future<void> _onAcceptBid(
    BiddingAcceptBid event,
    Emitter<BiddingState> emit,
  ) async {
    final ride = state.ride;
    if (ride == null) return;

    emit(state.copyWith(status: BiddingStatus.loading, clearError: true));
    final result = await _rideRepository.acceptBid(ride.id, event.bidId);

    result.fold(
      (message) => emit(state.copyWith(
        status: BiddingStatus.waiting,
        errorMessage: message,
      )),
      (assignedRide) {
        _stopPolling();
        emit(state.copyWith(
          status: BiddingStatus.assigned,
          assignedRide: assignedRide,
          ride: assignedRide,
        ));
      },
    );
  }

  Future<void> _onRejectBid(
    BiddingRejectBid event,
    Emitter<BiddingState> emit,
  ) async {
    final ride = state.ride;
    if (ride == null) return;

    await _rideRepository.rejectBid(ride.id, event.bidId);
    add(const BiddingPollRequested());
  }

  Future<void> _onCancel(
    BiddingCancelRequested event,
    Emitter<BiddingState> emit,
  ) async {
    final ride = state.ride;
    if (ride == null) return;

    _stopPolling();
    final result = await _rideRepository.cancelRide(ride.id);
    result.fold(
      (message) => emit(state.copyWith(
        status: BiddingStatus.failure,
        errorMessage: message,
      )),
      (_) => emit(state.copyWith(status: BiddingStatus.cancelled)),
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      add(const BiddingPollRequested());
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
