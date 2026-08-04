import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../domain/enums/document_type.dart';
import '../../domain/enums/ride_status.dart';
import '../../domain/models/driver_model.dart';
import '../../domain/models/ride_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../services/local_demo_store.dart';
import '../mappers/model_mappers.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl(this._apiClient, this._authRepository);

  final ApiClient _apiClient;
  final AuthRepository _authRepository;
  final _demo = LocalDemoStore.instance;

  Future<bool> get _isLocal async {
    final token = await _authRepository.getStoredToken();
    return _authRepository.isLocalToken(token);
  }

  @override
  Future<Either<String, DriverModel>> register({
    required String vehicleMake,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleColor,
    required int vehicleYear,
  }) async {
    if (await _isLocal) {
      final user = await _authRepository.getStoredLocalUser();
      if (user == null) return const Left('Oturum bulunamadı');
      final driver = _demo.registerPendingDriver(
        user,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
        vehiclePlate: vehiclePlate,
        vehicleColor: vehicleColor,
      );
      return Right(driver);
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.driverRegister,
        data: {
          'make': vehicleMake,
          'model': vehicleModel,
          'plate_number': vehiclePlate,
          'color': vehicleColor,
          'year': vehicleYear,
        },
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final driver = data['driver'] ?? data;
      if (driver is! Map<String, dynamic>) {
        return const Left('Invalid driver response');
      }
      return Right(ModelMappers.driverFromJson(driver));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, DriverModel>> getProfile() async {
    if (await _isLocal) {
      final user = await _authRepository.getStoredLocalUser();
      if (user == null) return const Left('Oturum bulunamadı');
      final driver = _demo.existingDriverProfile(user);
      if (driver == null) {
        return const Left('Driver profile not found.');
      }
      return Right(driver);
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.driverProfile,
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final driver = data['driver'] ?? data;
      if (driver is! Map<String, dynamic>) {
        return const Left('Invalid driver response');
      }
      return Right(ModelMappers.driverFromJson(driver));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> uploadDocument({
    required DocumentType type,
    required String filePath,
  }) async {
    if (await _isLocal) {
      _demo.markDocumentUploaded(type.value);
      return const Right(null);
    }
    try {
      final formData = FormData.fromMap({
        'type': type.value,
        'document': await MultipartFile.fromFile(filePath),
      });
      await _apiClient.post(
        ApiEndpoints.driverDocuments,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> goOnline({
    required double latitude,
    required double longitude,
  }) async {
    if (await _isLocal) {
      _demo.setOnline(true);
      return const Right(null);
    }
    try {
      await _apiClient.post(
        ApiEndpoints.driverOnline,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> goOffline() async {
    if (await _isLocal) {
      _demo.setOnline(false);
      return const Right(null);
    }
    try {
      await _apiClient.post(ApiEndpoints.driverOffline);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
  }) async {
    if (await _isLocal) return const Right(null);
    try {
      await _apiClient.post(
        ApiEndpoints.driverLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (heading != null) 'heading': heading,
        },
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<RideModel>>> getPendingRides() async {
    if (await _isLocal) {
      return Right(_demo.pendingForDriver());
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.driverRidesPending,
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
  Future<Either<String, RideModel?>> getActiveRide() async {
    if (await _isLocal) {
      return Right(_demo.driverActiveRide);
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.driverRidesActive,
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
        ApiEndpoints.driverRidesHistory,
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
  Future<Either<String, void>> acceptOffer(int rideId) async {
    if (await _isLocal) {
      final user = await _authRepository.getStoredLocalUser();
      final driver = user == null ? null : _demo.driverFor(user);
      _demo.acceptAsDriver(rideId, driver?.id ?? 7001);
      return const Right(null);
    }
    try {
      await _apiClient.post(ApiEndpoints.driverRideAccept(rideId));
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> submitBid(int rideId, double amount) async {
    if (await _isLocal) {
      _demo.acceptAsDriver(rideId, 7001);
      return const Right(null);
    }
    try {
      await _apiClient.post(
        ApiEndpoints.driverRideBid(rideId),
        data: {'amount': amount},
      );
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> rejectRide(int rideId) async {
    if (await _isLocal) {
      _demo.rejectAsDriver(rideId);
      return const Right(null);
    }
    try {
      await _apiClient.post(ApiEndpoints.driverRideReject(rideId));
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, RideModel>> markArrived(int rideId) async {
    if (await _isLocal) {
      return Right(_demo.advance(rideId, RideStatus.driverArrived));
    }
    return _rideAction(ApiEndpoints.driverRideArrived(rideId));
  }

  @override
  Future<Either<String, RideModel>> startRide(int rideId) async {
    if (await _isLocal) {
      return Right(_demo.advance(rideId, RideStatus.inProgress));
    }
    return _rideAction(ApiEndpoints.driverRideStart(rideId));
  }

  @override
  Future<Either<String, RideModel>> completeRide(int rideId) async {
    if (await _isLocal) {
      return Right(_demo.advance(rideId, RideStatus.completed));
    }
    return _rideAction(ApiEndpoints.driverRideComplete(rideId));
  }

  @override
  Future<Either<String, RideModel>> cancelRide(
    int rideId, {
    String? reason,
  }) async {
    if (await _isLocal) {
      return Right(_demo.advance(rideId, RideStatus.cancelledByDriver));
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.driverRideCancel(rideId),
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

  Future<Either<String, RideModel>> _rideAction(String endpoint) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(endpoint);
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
}
