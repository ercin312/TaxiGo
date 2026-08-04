import 'package:equatable/equatable.dart';

class FareEstimateModel extends Equatable {
  const FareEstimateModel({
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.fare,
    this.nearbyDriversCount = 0,
    this.discountAmount,
    this.finalFare,
  });

  final double distanceKm;
  final int estimatedDurationMinutes;
  final double fare;
  final int nearbyDriversCount;
  final double? discountAmount;
  final double? finalFare;

  double get totalFare => finalFare ?? fare;

  @override
  List<Object?> get props => [
        distanceKm,
        estimatedDurationMinutes,
        fare,
        nearbyDriversCount,
        discountAmount,
        finalFare,
      ];
}
