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

class BookingOfferAdjusted extends BookingEvent {
  const BookingOfferAdjusted(this.delta);

  final double delta;

  @override
  List<Object?> get props => [delta];
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
    this.paymentMethod = PaymentMethod.cash,
    this.promoCode,
    this.offeredFare,
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
  final PaymentMethod paymentMethod;
  final String? promoCode;
  final double? offeredFare;
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
    PaymentMethod? paymentMethod,
    String? promoCode,
    double? offeredFare,
    RideModel? createdRide,
    String? errorMessage,
    bool clearError = false,
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
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCode: promoCode ?? this.promoCode,
      offeredFare: offeredFare ?? this.offeredFare,
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
        paymentMethod,
        promoCode,
        offeredFare,
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
    on<BookingPaymentMethodChanged>(_onPaymentChanged);
    on<BookingOfferAdjusted>(_onOfferAdjusted);
    on<BookingSubmitRequested>(_onSubmit);
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

  Future<void> _onPaymentChanged(
    BookingPaymentMethodChanged event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(paymentMethod: event.paymentMethod));
  }

  Future<void> _onSubmit(
    BookingSubmitRequested event,
    Emitter<BookingState> emit,
  ) async {
    if (state.pickupLat == null ||
        state.dropoffLat == null ||
        state.pickupAddress == null ||
        state.dropoffAddress == null) {
      return;
    }

    emit(state.copyWith(status: BookingStatus.loading, clearError: true));
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
      offeredFare: state.offeredFare ?? state.estimate?.totalFare,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: error,
      )),
      (ride) => emit(state.copyWith(
        status: BookingStatus.booked,
        createdRide: ride,
      )),
    );
  }
}
