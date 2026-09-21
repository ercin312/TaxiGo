import 'package:dartz/dartz.dart';

import '../../domain/models/ride_comms_models.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/ride_comms_repository.dart';
import '../../services/local_demo_store.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';

class RideCommsRepositoryImpl implements RideCommsRepository {
  RideCommsRepositoryImpl(this._apiClient, this._authRepository);

  final ApiClient _apiClient;
  final AuthRepository _authRepository;
  final _demo = LocalDemoStore.instance;

  Future<bool> get _isLocal async {
    final token = await _authRepository.getStoredToken();
    return _authRepository.isLocalToken(token);
  }

  static const _demoTemplates = <RideMessageTemplate>[
    RideMessageTemplate(key: 'where_are_you', body: 'Where are you?'),
    RideMessageTemplate(key: 'im_outside', body: "I'm outside."),
    RideMessageTemplate(key: 'at_the_door', body: "I'm at the door / entrance."),
    RideMessageTemplate(key: 'luggage', body: 'I have luggage.'),
    RideMessageTemplate(key: 'running_late', body: "I'll be 2–3 minutes late."),
    RideMessageTemplate(
      key: 'cant_find',
      body: "I can't find you — can you call?",
    ),
    RideMessageTemplate(key: 'ok', body: 'OK, got it.'),
    RideMessageTemplate(key: 'on_my_way', body: "I'm on my way."),
  ];

  @override
  Future<Either<String, List<RideMessageModel>>> getMessages(int rideId) async {
    if (await _isLocal) {
      return Right(_demo.rideMessages(rideId));
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.rideMessages(rideId),
      );
      final raw = response.data?['messages'];
      if (raw is! List) return const Right([]);
      return Right(
        raw
            .whereType<Map>()
            .map((e) => RideMessageModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<RideMessageTemplate>>> getTemplates(
    int rideId,
  ) async {
    if (await _isLocal) {
      return const Right(_demoTemplates);
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.rideMessages(rideId),
      );
      final raw = response.data?['templates'];
      if (raw is! List) return const Right(_demoTemplates);
      return Right(
        raw
            .whereType<Map>()
            .map(
              (e) => RideMessageTemplate.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
      );
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, RideMessageModel>> sendMessage(
    int rideId, {
    String? body,
    String? templateKey,
  }) async {
    if (await _isLocal) {
      final text = templateKey != null
          ? _demoTemplates
              .firstWhere(
                (t) => t.key == templateKey,
                orElse: () => RideMessageTemplate(
                  key: templateKey,
                  body: body ?? '',
                ),
              )
              .body
          : (body ?? '');
      return Right(_demo.addRideMessage(rideId, text, templateKey));
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rideMessages(rideId),
        data: {
          if (body != null && body.isNotEmpty) 'body': body,
          if (templateKey != null) 'template_key': templateKey,
        },
      );
      final raw = response.data?['message'];
      if (raw is! Map) {
        return const Left('Invalid message response');
      }
      return Right(
        RideMessageModel.fromJson(Map<String, dynamic>.from(raw)),
      );
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, MaskedCallSession>> startMaskedCall(int rideId) async {
    if (await _isLocal) {
      return Right(
        MaskedCallSession(
          sessionRef: 'CALL-LOCAL-$rideId',
          dialNumber: null,
          displayLabel: 'Private number',
          provider: 'stub',
          instructions:
              'Call request sent. The other party is notified without sharing numbers.',
        ),
      );
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.rideMaskedCall(rideId),
      );
      final raw = response.data?['call'];
      if (raw is! Map) {
        return const Left('Invalid call response');
      }
      return Right(
        MaskedCallSession.fromJson(Map<String, dynamic>.from(raw)),
      );
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
