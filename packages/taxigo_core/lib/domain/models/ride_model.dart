import 'package:equatable/equatable.dart';

import '../enums/payment_method.dart';
import '../enums/ride_status.dart';

class RideModel extends Equatable {
  const RideModel({
    required this.id,
    required this.reference,
    required this.passengerId,
    this.driverId,
    this.status = RideStatus.pending,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.dropoffAddress,
    this.estimatedDistanceKm,
    this.estimatedDurationMinutes,
    this.estimatedFare,
    this.offeredFare,
    this.minimumFare,
    this.isBidding = true,
    this.finalFare,
    this.distanceKm,
    this.durationMinutes,
    this.paymentMethod = PaymentMethod.cash,
    this.promoCodeId,
    this.discountAmount,
    this.commissionAmount,
    this.cancellationReason,
    this.driverAssignedAt,
    this.driverArrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.driverName,
    this.vehiclePlate,
  });

  final int id;
  final String reference;
  final int passengerId;
  final int? driverId;
  final RideStatus status;
  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String dropoffAddress;
  final double? estimatedDistanceKm;
  final int? estimatedDurationMinutes;
  final double? estimatedFare;
  final double? offeredFare;
  final double? minimumFare;
  final bool isBidding;
  final double? finalFare;
  final double? distanceKm;
  final int? durationMinutes;
  final PaymentMethod paymentMethod;
  final int? promoCodeId;
  final double? discountAmount;
  final double? commissionAmount;
  final String? cancellationReason;
  final DateTime? driverAssignedAt;
  final DateTime? driverArrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? driverName;
  final String? vehiclePlate;

  bool get isActive => status.isActive;

  RideModel copyWith({
    int? id,
    String? reference,
    int? passengerId,
    int? driverId,
    RideStatus? status,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    double? dropoffLatitude,
    double? dropoffLongitude,
    String? dropoffAddress,
    double? estimatedDistanceKm,
    int? estimatedDurationMinutes,
    double? estimatedFare,
    double? offeredFare,
    double? minimumFare,
    bool? isBidding,
    double? finalFare,
    double? distanceKm,
    int? durationMinutes,
    PaymentMethod? paymentMethod,
    int? promoCodeId,
    double? discountAmount,
    double? commissionAmount,
    String? cancellationReason,
    DateTime? driverAssignedAt,
    DateTime? driverArrivedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? driverName,
    String? vehiclePlate,
  }) {
    return RideModel(
      id: id ?? this.id,
      reference: reference ?? this.reference,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffLatitude: dropoffLatitude ?? this.dropoffLatitude,
      dropoffLongitude: dropoffLongitude ?? this.dropoffLongitude,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      estimatedDistanceKm: estimatedDistanceKm ?? this.estimatedDistanceKm,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      offeredFare: offeredFare ?? this.offeredFare,
      minimumFare: minimumFare ?? this.minimumFare,
      isBidding: isBidding ?? this.isBidding,
      finalFare: finalFare ?? this.finalFare,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      promoCodeId: promoCodeId ?? this.promoCodeId,
      discountAmount: discountAmount ?? this.discountAmount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      driverAssignedAt: driverAssignedAt ?? this.driverAssignedAt,
      driverArrivedAt: driverArrivedAt ?? this.driverArrivedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      driverName: driverName ?? this.driverName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        reference,
        passengerId,
        driverId,
        status,
        pickupLatitude,
        pickupLongitude,
        pickupAddress,
        dropoffLatitude,
        dropoffLongitude,
        dropoffAddress,
        estimatedDistanceKm,
        estimatedDurationMinutes,
        estimatedFare,
        offeredFare,
        minimumFare,
        isBidding,
        finalFare,
        distanceKm,
        durationMinutes,
        paymentMethod,
        promoCodeId,
        discountAmount,
        commissionAmount,
        cancellationReason,
        driverAssignedAt,
        driverArrivedAt,
        startedAt,
        completedAt,
        cancelledAt,
        expiresAt,
        createdAt,
        updatedAt,
        driverName,
        vehiclePlate,
      ];
}
