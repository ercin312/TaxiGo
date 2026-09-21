import '../core/constants/app_constants.dart';
import '../domain/enums/driver_approval_status.dart';
import '../domain/enums/payment_method.dart';
import '../domain/enums/ride_status.dart';
import '../domain/models/driver_model.dart';
import '../domain/models/ride_model.dart';

/// Fixed App Store / Play review accounts and seed content.
abstract final class AppReviewSeed {
  static const passengerPhone = '+905550000001';
  static const driverPhone = '+905550000002';
  static const password = '123456';

  static bool isReviewPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    final normalized = phone.replaceAll(RegExp(r'\s+'), '');
    return normalized == passengerPhone ||
        normalized == driverPhone ||
        normalized == '905550000001' ||
        normalized == '905550000002';
  }

  static bool isReviewDriverPhone(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    final normalized = phone.replaceAll(RegExp(r'\s+'), '');
    return normalized == driverPhone || normalized == '905550000002';
  }

  /// Approved taxi profile so App Review driver login never dead-ends.
  static DriverModel driverProfile({int userId = 2}) {
    return DriverModel(
      id: userId,
      userId: userId,
      approvalStatus: DriverApprovalStatus.approved,
      isOnline: false,
      currentLatitude: AppConstants.defaultLatitude,
      currentLongitude: AppConstants.defaultLongitude,
      heading: 0,
      ratingAverage: 4.9,
      ratingCount: 128,
      totalRides: 420,
      approvedAt: DateTime.now().toUtc().subtract(const Duration(days: 30)),
      vehicleMake: 'Toyota',
      vehicleModel: 'Corolla',
      vehiclePlate: 'PG TG 100',
      vehicleColor: 'White',
    );
  }

  static List<RideModel> rideHistory() {
    final now = DateTime.now().toUtc();
    return [
      RideModel(
        id: 1001,
        reference: 'TG-REVIEW-001',
        passengerId: 1,
        driverId: 2,
        status: RideStatus.completed,
        pickupLatitude: 42.4410,
        pickupLongitude: 19.2628,
        pickupAddress: 'Trg Republike, Podgorica',
        dropoffLatitude: 42.2864,
        dropoffLongitude: 18.8400,
        dropoffAddress: 'Budva Old Town',
        finalFare: 35.5,
        paymentMethod: PaymentMethod.cash,
        createdAt: now.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(days: 2)),
        driverName: 'App Review Driver',
        vehiclePlate: 'PG TG 100',
      ),
      RideModel(
        id: 1002,
        reference: 'TG-REVIEW-002',
        passengerId: 1,
        driverId: 2,
        status: RideStatus.completed,
        pickupLatitude: 42.4340,
        pickupLongitude: 18.7064,
        pickupAddress: 'Porto Montenegro, Tivat',
        dropoffLatitude: 42.4247,
        dropoffLongitude: 18.7712,
        dropoffAddress: 'Kotor Old Town',
        finalFare: 18.0,
        paymentMethod: PaymentMethod.wallet,
        createdAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
        driverName: 'App Review Driver',
        vehiclePlate: 'PG TG 100',
      ),
    ];
  }
}
