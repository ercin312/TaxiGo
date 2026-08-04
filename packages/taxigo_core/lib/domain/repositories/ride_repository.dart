import 'package:dartz/dartz.dart';

import '../enums/payment_method.dart';
import '../models/fare_estimate_model.dart';
import '../models/rating_model.dart';
import '../models/ride_bid_model.dart';
import '../models/ride_model.dart';

abstract class RideRepository {
  Future<Either<String, FareEstimateModel>> estimateFare({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    String? vehicleType,
    String? promoCode,
  });

  Future<Either<String, RideModel>> requestRide({
    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required String dropoffAddress,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String? vehicleType,
    String? promoCode,
    double? offeredFare,
  });

  Future<Either<String, List<RideBidModel>>> getRideBids(int rideId);

  Future<Either<String, RideModel>> acceptBid(int rideId, int bidId);

  Future<Either<String, void>> rejectBid(int rideId, int bidId);

  Future<Either<String, RideModel>> updateOfferedFare(
    int rideId, {
    required double offeredFare,
  });

  Future<Either<String, RideModel?>> getActiveRide();

  Future<Either<String, List<RideModel>>> getRideHistory({int page = 1});

  Future<Either<String, RideModel>> getRide(int rideId);

  Future<Either<String, RideModel>> cancelRide(
    int rideId, {
    String? reason,
  });

  Future<Either<String, RatingModel>> rateRide(
    int rideId, {
    required int score,
    String? comment,
  });

  Future<Either<String, String>> shareTrip(int rideId);
}
