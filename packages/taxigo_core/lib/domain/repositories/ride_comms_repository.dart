import 'package:dartz/dartz.dart';

import '../models/ride_comms_models.dart';

abstract class RideCommsRepository {
  Future<Either<String, List<RideMessageModel>>> getMessages(int rideId);

  Future<Either<String, List<RideMessageTemplate>>> getTemplates(int rideId);

  Future<Either<String, RideMessageModel>> sendMessage(
    int rideId, {
    String? body,
    String? templateKey,
  });

  Future<Either<String, MaskedCallSession>> startMaskedCall(int rideId);
}
