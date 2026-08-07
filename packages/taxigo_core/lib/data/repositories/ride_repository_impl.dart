import 'package:dartz/dartz.dart';

import '../../domain/enums/payment_method.dart';
import '../../domain/enums/ride_status.dart';
import '../../domain/models/fare_estimate_model.dart';
import '../../domain/models/rating_model.dart';
import '../../domain/models/ride_bid_model.dart';
import '../../domain/models/ride_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/ride_repository.dart';
import '../../services/local_demo_store.dart';
import '../mappers/model_mappers.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';

class RideRepositoryImpl implements RideRepository {
  RideRepositoryImpl(this._apiClient, this._authRepository);

  final ApiClient _apiClient;
  final AuthRepository _authRepository;
  final _demo = LocalDemoStore.instance;

  Future<bool> get _isLocal async {
    final token = await _authRepository.getStoredToken();
    return _authRepository.isLocalToken(token);
  }

  @override
  Future<Either<String, FareEstimateModel>> estimateFare({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    String? vehicleType,
    String? promoCode,
  }) async {
    if (await _isLocal) {
      return Right(
        _demo.estimateFare(
          pickupLatitude: pickupLatitude,
          pickupLongitude: pickupLongitude,
          dropoffLatitude: dropoffLatitude,
          dropoffLongitude: dropoffLongitude,
          vehicleType: vehicleType,
        ),
      );
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.ridesEta,
        data: {
          'pickup_latitude': pickupLatitude,
          'pickup_longitude': pickupLongitude,
          'dropoff_latitude': dropoffLatitude,
          'dropoff_longitude': dropoffLongitude,
          if (vehicleType != null) 'vehicle_type': vehicleType,
          if (promoCode != null) 'promo_code': promoCode,
        },
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      return Right(ModelMappers.fareEstimateFromJson(data));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
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
  }) async {
    if (await _isLocal) {
      final user = await _authRepository.getStoredLocalUser();
      if (user == null) return const Left('Oturum bulunamadı');
      return Right(
        _demo.createRide(
          passenger: user,
          pickupLatitude: pickupLatitude,
          pickupLongitude: pickupLongitude,
          pickupAddress: pickupAddress,
          dropoffLatitude: dropoffLatitude,
          dropoffLongitude: dropoffLongitude,
          dropoffAddress: dropoffAddress,
          paymentMethod: paymentMethod,
          vehicleType: vehicleType,
          offeredFare: offeredFare,
        ),
      );
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rides,
        data: {
          'pickup_latitude': pickupLatitude,
          'pickup_longitude': pickupLongitude,
          'pickup_address': pickupAddress,
          'dropoff_latitude': dropoffLatitude,
          'dropoff_longitude': dropoffLongitude,
          'dropoff_address': dropoffAddress,
          'payment_method': paymentMethod.value,
          if (vehicleType != null) 'vehicle_type': vehicleType,
          if (promoCode != null) 'promo_code': promoCode,
          if (offeredFare != null) 'offered_fare': offeredFare,
        },
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final ride = data['ride'] ?? data;
      if (ride is! Map<String, dynamic>) {
        return const Left('Invalid ride response');
      }
      return Right(ModelMappers.rideFromJson(ride));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, RideModel?>> getActiveRide() async {
    if (await _isLocal) {
      return Right(_demo.passengerActiveRide);
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.ridesActive,
      );
      final data = response.data;
      if (data == null) return const Right(null);
      final ride = data['ride'] ?? data;
      if (ride == null) return const Right(null);
      if (ride is! Map<String, dynamic>) return const Right(null);
      return Right(ModelMappers.rideFromJson(ride));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<RideModel>>> getRideHistory({int page = 1}) async {
    if (await _isLocal) {
      return Right(_demo.history());
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.ridesHistory,
        queryParameters: {'page': page},
      );
      final data = response.data;
      if (data == null) return const Right([]);
      final rides = data['data'] ?? data['rides'] ?? data;
      return Right(ModelMappers.ridesFromJsonList(rides));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, RideModel>> getRide(int rideId) async {
    if (await _isLocal) {
      final ride = _demo.getRide(rideId);
      if (ride == null) return const Left('Yolculuk bulunamadı');
      return Right(ride);
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.ride(rideId),
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final ride = data['ride'] ?? data;
      if (ride is! Map<String, dynamic>) {
        return const Left('Invalid ride response');
      }
      return Right(ModelMappers.rideFromJson(ride));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, RideModel>> cancelRide(
    int rideId, {
    String? reason,
  }) async {
    if (await _isLocal) {
      try {
        return Right(_demo.cancelPassenger(rideId, reason: reason));
      } catch (e) {
        return Left(e.toString());
      }
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rideCancel(rideId),
        data: {if (reason != null) 'reason': reason},
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final ride = data['ride'] ?? data;
      if (ride is! Map<String, dynamic>) {
        return const Left('Invalid ride response');
      }
      return Right(ModelMappers.rideFromJson(ride));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, RatingModel>> rateRide(
    int rideId, {
    required int score,
    String? comment,
  }) async {
    if (await _isLocal) {
      return Right(
        RatingModel(
          id: 1,
          rideId: rideId,
          raterId: 1,
          ratedId: 7101,
          score: score,
          comment: comment,
          createdAt: DateTime.now(),
        ),
      );
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rideRate(rideId),
        data: {
          'score': score,
          if (comment != null) 'comment': comment,
        },
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final rating = data['rating'] ?? data;
      if (rating is! Map<String, dynamic>) {
        return const Left('Invalid rating response');
      }
      return Right(ModelMappers.ratingFromJson(rating));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<RideBidModel>>> getRideBids(int rideId) async {
    if (await _isLocal) {
      final ride = _demo.getRide(rideId);
      if (ride == null) return const Right([]);
      // Virtual auto-assign — no live bids needed.
      if (ride.status != RideStatus.pending) return const Right([]);
      return Right([
        RideBidModel(
          id: 1,
          rideId: rideId,
          driverId: 7101,
          amount: ride.offeredFare ?? ride.estimatedFare ?? 10,
          status: 'pending',
          expiresAt: DateTime.now().add(const Duration(minutes: 2)),
          driverName: 'Demo Taksi',
          driverRating: 4.9,
          vehicleDescription: 'Toyota Corolla · 34 TG 01',
        ),
      ]);
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.rideBids(rideId),
      );
      final data = response.data;
      if (data == null) return const Right([]);
      final bids = data['bids'] ?? data['data'] ?? data;
      return Right(ModelMappers.rideBidsFromJsonList(bids));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, RideModel>> acceptBid(int rideId, int bidId) async {
    if (await _isLocal) {
      _demo.acceptAsDriver(rideId, 7101);
      final ride = _demo.getRide(rideId);
      if (ride == null) return const Left('Yolculuk bulunamadı');
      return Right(ride);
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rideBidAccept(rideId, bidId),
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final ride = data['ride'] ?? data;
      if (ride is! Map<String, dynamic>) {
        return const Left('Invalid ride response');
      }
      return Right(ModelMappers.rideFromJson(ride));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> rejectBid(int rideId, int bidId) async {
    if (await _isLocal) return const Right(null);
    try {
      await _apiClient.post(ApiEndpoints.rideBidReject(rideId, bidId));
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, RideModel>> updateOfferedFare(
    int rideId, {
    required double offeredFare,
  }) async {
    if (await _isLocal) {
      final ride = _demo.getRide(rideId);
      if (ride == null) return const Left('Yolculuk bulunamadı');
      final updated = ride.copyWith(offeredFare: offeredFare);
      return Right(updated);
    }
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.rideOffer(rideId),
        data: {'offered_fare': offeredFare},
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final ride = data['ride'] ?? data;
      if (ride is! Map<String, dynamic>) {
        return const Left('Invalid ride response');
      }
      return Right(ModelMappers.rideFromJson(ride));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> shareTrip(int rideId) async {
    if (await _isLocal) {
      final ride = _demo.getRide(rideId);
      final reference = ride?.reference ?? 'DEMO-$rideId';
      final token = 'local-${rideId.toRadixString(16)}';
      return Right(
        'https://taxigo.app/shared/trip/$reference?token=$token',
      );
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rideShare(rideId),
      );
      final data = response.data;
      final url = data?['share_url']?.toString() ?? data?['url']?.toString();
      if (url == null || url.isEmpty) {
        return const Left('Paylaşım linki alınamadı');
      }
      return Right(url);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
