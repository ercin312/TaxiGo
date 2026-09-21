import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingLocationsSet extends BookingEvent {
  const BookingLocationsSet({
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.dropoffAddress,
  });

  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double dropoffLat;
  final double dropoffLng;
  final String dropoffAddress;

  @override
  List<Object?> get props => [
        pickupLat,
        pickupLng,
        pickupAddress,
        dropoffLat,
        dropoffLng,
        dropoffAddress,
      ];
}

class BookingEstimateRequested extends BookingEvent {
  const BookingEstimateRequested({
    this.vehicleType = 'standard',
    this.promoCode,
  });

  final String vehicleType;
  final String? promoCode;

  @override
  List<Object?> get props => [vehicleType, promoCode];
}

class BookingVehicleTypeChanged extends BookingEvent {
  const BookingVehicleTypeChanged(this.vehicleType);

  final String vehicleType;

  @override
  List<Object?> get props => [vehicleType];
}

class BookingPaymentMethodChanged extends BookingEvent {
  const BookingPaymentMethodChanged(this.paymentMethod);

  final PaymentMethod paymentMethod;

  @override
  List<Object?> get props => [paymentMethod];
}

class BookingSubmitRequested extends BookingEvent {
  const BookingSubmitRequested();
}

class BookingMatchModeChanged extends BookingEvent {
  const BookingMatchModeChanged(this.matchMode);

  /// `instant` | `bidding`
  final String matchMode;

  @override
  List<Object?> get props => [matchMode];
}

class BookingOfferAdjusted extends BookingEvent {
  const BookingOfferAdjusted(this.delta);

  final double delta;

  @override
  List<Object?> get props => [delta];
}

class BookingProductModeChanged extends BookingEvent {
  const BookingProductModeChanged(this.productMode);

  final String productMode;

  @override
  List<Object?> get props => [productMode];
}

class BookingNoteChanged extends BookingEvent {
  const BookingNoteChanged(this.note);

  final String note;

  @override
  List<Object?> get props => [note];
}

class BookingScheduleRequested extends BookingEvent {
  const BookingScheduleRequested(this.scheduledAt);

  final DateTime scheduledAt;

  @override
  List<Object?> get props => [scheduledAt];
}

class BookingState extends Equatable {
  const BookingState({
    this.status = BookingStatus.initial,
    this.pickupLat,
    this.pickupLng,
    this.pickupAddress,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffAddress,
    this.estimate,
    this.vehicleType = 'standard',
    this.productMode = 'taxi',
    this.matchMode = 'instant',
    this.paymentMethod = PaymentMethod.cash,
    this.promoCode,
    this.offeredFare,
    this.passengerNote,
    this.scheduledAt,
    this.createdRide,
    this.errorMessage,
  });

  final BookingStatus status;
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupAddress;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffAddress;
  final FareEstimateModel? estimate;
  final String vehicleType;
  final String productMode;
  final String matchMode;
  final PaymentMethod paymentMethod;
  final String? promoCode;
  final double? offeredFare;
  final String? passengerNote;
  final DateTime? scheduledAt;
  final RideModel? createdRide;
  final String? errorMessage;

  BookingState copyWith({
    BookingStatus? status,
    double? pickupLat,
    double? pickupLng,
    String? pickupAddress,
    double? dropoffLat,
    double? dropoffLng,
    String? dropoffAddress,
    FareEstimateModel? estimate,
    String? vehicleType,
    String? productMode,
    String? matchMode,
    PaymentMethod? paymentMethod,
    String? promoCode,
    double? offeredFare,
    String? passengerNote,
    DateTime? scheduledAt,
    RideModel? createdRide,
    String? errorMessage,
    bool clearError = false,
    bool clearScheduledAt = false,
  }) {
    return BookingState(
      status: status ?? this.status,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLat: dropoffLat ?? this.dropoffLat,
      dropoffLng: dropoffLng ?? this.dropoffLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      estimate: estimate ?? this.estimate,
      vehicleType: vehicleType ?? this.vehicleType,
      productMode: productMode ?? this.productMode,
      matchMode: matchMode ?? this.matchMode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      offeredFare: offeredFare ?? this.offeredFare,
      passengerNote: passengerNote ?? this.passengerNote,
      scheduledAt:
          clearScheduledAt ? null : (scheduledAt ?? this.scheduledAt),
      createdRide: createdRide ?? this.createdRide,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        pickupLat,
        pickupLng,
        pickupAddress,
        dropoffLat,
        dropoffLng,
        dropoffAddress,
        estimate,
        vehicleType,
        productMode,
        matchMode,
        paymentMethod,
        promoCode,
        offeredFare,
        passengerNote,
        scheduledAt,
        createdRide,
        errorMessage,
      ];
}

enum BookingStatus { initial, loading, estimated, booked, failure }

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({required RideRepository rideRepository})
      : _rideRepository = rideRepository,
        super(const BookingState()) {
    on<BookingLocationsSet>(_onLocationsSet);
    on<BookingEstimateRequested>(_onEstimate);
    on<BookingVehicleTypeChanged>(_onVehicleChanged);
    on<BookingProductModeChanged>(_onProductModeChanged);
    on<BookingMatchModeChanged>(_onMatchModeChanged);
    on<BookingPaymentMethodChanged>(_onPaymentChanged);
    on<BookingNoteChanged>(_onNoteChanged);
    on<BookingOfferAdjusted>(_onOfferAdjusted);
    on<BookingSubmitRequested>(_onSubmit);
    on<BookingScheduleRequested>(_onSchedule);
  }

  final RideRepository _rideRepository;

  static const double fareStep = 10;

  Future<void> _onLocationsSet(
    BookingLocationsSet event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(
      pickupLat: event.pickupLat,
      pickupLng: event.pickupLng,
      pickupAddress: event.pickupAddress,
      dropoffLat: event.dropoffLat,
      dropoffLng: event.dropoffLng,
      dropoffAddress: event.dropoffAddress,
    ));
    add(BookingEstimateRequested(vehicleType: state.vehicleType));
  }

  Future<void> _onEstimate(
    BookingEstimateRequested event,
    Emitter<BookingState> emit,
  ) async {
    if (state.pickupLat == null || state.dropoffLat == null) return;

    emit(state.copyWith(status: BookingStatus.loading, clearError: true));
    final result = await _rideRepository.estimateFare(
      pickupLatitude: state.pickupLat!,
      pickupLongitude: state.pickupLng!,
      dropoffLatitude: state.dropoffLat!,
      dropoffLongitude: state.dropoffLng!,
      vehicleType: event.vehicleType,
      promoCode: event.promoCode ?? state.promoCode,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: error,
      )),
      (estimate) => emit(state.copyWith(
        status: BookingStatus.estimated,
        estimate: estimate,
        vehicleType: event.vehicleType,
        promoCode: event.promoCode ?? state.promoCode,
        offeredFare: estimate.totalFare,
      )),
    );
  }

  void _onOfferAdjusted(
    BookingOfferAdjusted event,
    Emitter<BookingState> emit,
  ) {
    final minimum = state.estimate?.totalFare ?? 0;
    final current = state.offeredFare ?? minimum;
    final next = current + event.delta;
    if (next < minimum) return;
    emit(state.copyWith(offeredFare: next));
  }

  Future<void> _onVehicleChanged(
    BookingVehicleTypeChanged event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(vehicleType: event.vehicleType));
    add(BookingEstimateRequested(vehicleType: event.vehicleType));
  }

  Future<void> _onProductModeChanged(
    BookingProductModeChanged event,
    Emitter<BookingState> emit,
  ) async {
    final nextType = event.productMode == 'transfer'
        ? (state.vehicleType == 'standard' ? 'van' : state.vehicleType)
        : (state.vehicleType == 'van' ? 'standard' : state.vehicleType);
    // Transfer / airport: default to instant fixed-price match.
    final nextMatch = event.productMode == 'transfer' ? 'instant' : state.matchMode;
    emit(state.copyWith(
      productMode: event.productMode,
      vehicleType: nextType,
      matchMode: nextMatch,
      offeredFare: state.estimate?.totalFare,
    ));
    add(BookingEstimateRequested(vehicleType: nextType));
  }

  void _onMatchModeChanged(
    BookingMatchModeChanged event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(
      matchMode: event.matchMode,
      offeredFare: event.matchMode == 'instant'
          ? state.estimate?.totalFare
          : state.offeredFare,
    ));
  }

  Future<void> _onPaymentChanged(
    BookingPaymentMethodChanged event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(paymentMethod: event.paymentMethod));
  }

  void _onNoteChanged(
    BookingNoteChanged event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(passengerNote: event.note));
  }

  Future<void> _onSubmit(
    BookingSubmitRequested event,
    Emitter<BookingState> emit,
  ) async {
    await _createRide(emit, scheduledAt: null);
  }

  Future<void> _onSchedule(
    BookingScheduleRequested event,
    Emitter<BookingState> emit,
  ) async {
    await _createRide(emit, scheduledAt: event.scheduledAt);
  }

  Future<void> _createRide(
    Emitter<BookingState> emit, {
    required DateTime? scheduledAt,
  }) async {
    if (state.pickupLat == null ||
        state.dropoffLat == null ||
        state.pickupAddress == null ||
        state.dropoffAddress == null) {
      return;
    }

    emit(state.copyWith(status: BookingStatus.loading, clearError: true));
    final biddingOn = locator<FeatureModulesService>().bidding;
    final effectiveMatch = scheduledAt != null || !biddingOn
        ? 'instant'
        : state.matchMode;
    final result = await _rideRepository.requestRide(
      pickupLatitude: state.pickupLat!,
      pickupLongitude: state.pickupLng!,
      pickupAddress: state.pickupAddress!,
      dropoffLatitude: state.dropoffLat!,
      dropoffLongitude: state.dropoffLng!,
      dropoffAddress: state.dropoffAddress!,
      paymentMethod: state.paymentMethod,
      vehicleType: state.vehicleType,
      promoCode: state.promoCode,
      offeredFare: effectiveMatch == 'bidding'
          ? (state.offeredFare ?? state.estimate?.totalFare)
          : state.estimate?.totalFare,
      productMode: state.productMode,
      matchMode: effectiveMatch,
      scheduledAt: scheduledAt,
      passengerNote: state.passengerNote,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: error,
      )),
      (ride) => emit(state.copyWith(
        status: BookingStatus.booked,
        createdRide: ride,
        scheduledAt: scheduledAt,
      )),
    );
  }
}
