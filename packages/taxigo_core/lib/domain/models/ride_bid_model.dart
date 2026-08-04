import 'package:equatable/equatable.dart';

class RideBidModel extends Equatable {
  const RideBidModel({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.amount,
    required this.status,
    this.expiresAt,
    this.driverName,
    this.driverRating,
    this.vehicleDescription,
    this.driverAvatar,
  });

  final int id;
  final int rideId;
  final int driverId;
  final double amount;
  final String status;
  final DateTime? expiresAt;
  final String? driverName;
  final double? driverRating;
  final String? vehicleDescription;
  final String? driverAvatar;

  int? get secondsRemaining {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  @override
  List<Object?> get props => [
        id,
        rideId,
        driverId,
        amount,
        status,
        expiresAt,
        driverName,
        driverRating,
        vehicleDescription,
        driverAvatar,
      ];
}
