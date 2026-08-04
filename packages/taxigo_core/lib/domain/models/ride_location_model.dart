import 'package:equatable/equatable.dart';

class RideLocationModel extends Equatable {
  const RideLocationModel({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final DateTime? recordedAt;

  RideLocationModel copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    double? speed,
    DateTime? recordedAt,
  }) {
    return RideLocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, heading, speed, recordedAt];
}
