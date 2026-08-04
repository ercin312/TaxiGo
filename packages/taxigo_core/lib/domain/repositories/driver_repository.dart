import 'package:dartz/dartz.dart';

import '../enums/document_type.dart';
import '../models/driver_model.dart';
import '../models/ride_model.dart';

abstract class DriverRepository {
  Future<Either<String, DriverModel>> register({
    required String vehicleMake,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleColor,
    required int vehicleYear,
  });

  Future<Either<String, DriverModel>> getProfile();

  Future<Either<String, void>> uploadDocument({
    required DocumentType type,
    required String filePath,
  });

  Future<Either<String, void>> goOnline({
    required double latitude,
    required double longitude,
  });

  Future<Either<String, void>> goOffline();

  Future<Either<String, void>> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
  });

  Future<Either<String, List<RideModel>>> getPendingRides();

  Future<Either<String, RideModel?>> getActiveRide();

  Future<Either<String, List<RideModel>>> getRideHistory({int page = 1});

  Future<Either<String, void>> acceptOffer(int rideId);

  Future<Either<String, void>> submitBid(int rideId, double amount);

  Future<Either<String, void>> rejectRide(int rideId);

  Future<Either<String, RideModel>> markArrived(int rideId);

  Future<Either<String, RideModel>> startRide(int rideId);

  Future<Either<String, RideModel>> completeRide(int rideId);

  Future<Either<String, RideModel>> cancelRide(
    int rideId, {
    String? reason,
  });
}
