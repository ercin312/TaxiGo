import 'package:equatable/equatable.dart';

import '../enums/driver_approval_status.dart';

class DriverModel extends Equatable {
  const DriverModel({
    required this.id,
    required this.userId,
    this.approvalStatus = DriverApprovalStatus.pending,
    this.isOnline = false,
    this.currentLatitude,
    this.currentLongitude,
    this.heading,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.totalRides = 0,
    this.lastLocationAt,
    this.approvedAt,
    this.rejectionReason,
    this.vehicleMake,
    this.vehicleModel,
    this.vehiclePlate,
    this.vehicleColor,
  });

  final int id;
  final int userId;
  final DriverApprovalStatus approvalStatus;
  final bool isOnline;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? heading;
  final double ratingAverage;
  final int ratingCount;
  final int totalRides;
  final DateTime? lastLocationAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? vehicleMake;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? vehicleColor;

  bool get isApproved => approvalStatus == DriverApprovalStatus.approved;

  DriverModel copyWith({
    int? id,
    int? userId,
    DriverApprovalStatus? approvalStatus,
    bool? isOnline,
    double? currentLatitude,
    double? currentLongitude,
    double? heading,
    double? ratingAverage,
    int? ratingCount,
    int? totalRides,
    DateTime? lastLocationAt,
    DateTime? approvedAt,
    String? rejectionReason,
    String? vehicleMake,
    String? vehicleModel,
    String? vehiclePlate,
    String? vehicleColor,
  }) {
    return DriverModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isOnline: isOnline ?? this.isOnline,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      heading: heading ?? this.heading,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      totalRides: totalRides ?? this.totalRides,
      lastLocationAt: lastLocationAt ?? this.lastLocationAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleColor: vehicleColor ?? this.vehicleColor,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        approvalStatus,
        isOnline,
        currentLatitude,
        currentLongitude,
        heading,
        ratingAverage,
        ratingCount,
        totalRides,
        lastLocationAt,
        approvedAt,
        rejectionReason,
        vehicleMake,
        vehicleModel,
        vehiclePlate,
        vehicleColor,
      ];
}
