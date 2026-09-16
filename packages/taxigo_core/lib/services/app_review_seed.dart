import '../domain/enums/payment_method.dart';
import '../domain/enums/ride_status.dart';
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

  static List<RideModel> rideHistory() {
    final now = DateTime.now().toUtc();
    return [
      RideModel(
        id: 1001,
        reference: 'TG-REVIEW-001',
        passengerId: 1,
        driverId: 2,
        status: RideStatus.completed,
        pickupLatitude: 41.01,
        pickupLongitude: 28.97,
        pickupAddress: 'Taksim Square',
        dropoffLatitude: 41.04,
        dropoffLongitude: 29.00,
        dropoffAddress: 'Besiktas Pier',
        finalFare: 185.5,
        paymentMethod: PaymentMethod.cash,
        createdAt: now.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(days: 2)),
        driverName: 'App Review Driver',
        vehiclePlate: '34 TG 100',
      ),
      RideModel(
        id: 1002,
        reference: 'TG-REVIEW-002',
        passengerId: 1,
        driverId: 2,
        status: RideStatus.completed,
        pickupLatitude: 41.04,
        pickupLongitude: 29.00,
        pickupAddress: 'Besiktas Pier',
        dropoffLatitude: 40.99,
        dropoffLongitude: 29.03,
        dropoffAddress: 'Kadikoy Ferry',
        finalFare: 210.0,
        paymentMethod: PaymentMethod.wallet,
        createdAt: now.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
        driverName: 'App Review Driver',
        vehiclePlate: '34 TG 100',
      ),
    ];
  }
}
