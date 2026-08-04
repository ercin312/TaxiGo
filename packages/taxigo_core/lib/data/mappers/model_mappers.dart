import '../../domain/enums/driver_approval_status.dart';
import '../../domain/enums/payment_method.dart';
import '../../domain/enums/ride_status.dart';
import '../../domain/models/complaint_model.dart';
import '../../domain/models/driver_model.dart';
import '../../domain/models/fare_estimate_model.dart';
import '../../domain/models/promo_model.dart';
import '../../domain/models/rating_model.dart';
import '../../domain/models/ride_bid_model.dart';
import '../../domain/models/ride_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/models/withdrawal_model.dart';

abstract final class ModelMappers {
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static UserModel userFromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      firebaseUid: json['firebase_uid']?.toString(),
      role: json['role']?.toString() ?? 'passenger',
      locale: json['locale']?.toString() ?? 'en',
      avatar: json['avatar']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1,
      fcmToken: json['fcm_token']?.toString(),
    );
  }

  static DriverModel driverFromJson(Map<String, dynamic> json) {
    final vehicle = json['vehicle'] as Map<String, dynamic>?;
    return DriverModel(
      id: _toInt(json['id']) ?? 0,
      userId: _toInt(json['user_id']) ?? 0,
      approvalStatus:
          DriverApprovalStatus.fromString(json['approval_status']?.toString()),
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      currentLatitude: _toDouble(json['current_latitude']),
      currentLongitude: _toDouble(json['current_longitude']),
      heading: _toDouble(json['heading']),
      ratingAverage: _toDouble(json['rating_average']) ?? 0,
      ratingCount: _toInt(json['rating_count']) ?? 0,
      totalRides: _toInt(json['total_rides']) ?? 0,
      lastLocationAt: _toDateTime(json['last_location_at']),
      approvedAt: _toDateTime(json['approved_at']),
      rejectionReason: json['rejection_reason']?.toString(),
      vehicleMake: vehicle?['make']?.toString(),
      vehicleModel: vehicle?['model']?.toString(),
      vehiclePlate: vehicle?['plate']?.toString(),
      vehicleColor: vehicle?['color']?.toString(),
    );
  }

  static RideModel rideFromJson(Map<String, dynamic> json) {
    return RideModel(
      id: _toInt(json['id']) ?? 0,
      reference: json['reference']?.toString() ?? '',
      passengerId: _toInt(json['passenger_id']) ?? 0,
      driverId: _toInt(json['driver_id']),
      status: RideStatus.fromString(json['status']?.toString()),
      pickupLatitude: _toDouble(json['pickup_latitude']) ?? 0,
      pickupLongitude: _toDouble(json['pickup_longitude']) ?? 0,
      pickupAddress: json['pickup_address']?.toString() ?? '',
      dropoffLatitude: _toDouble(json['dropoff_latitude']) ?? 0,
      dropoffLongitude: _toDouble(json['dropoff_longitude']) ?? 0,
      dropoffAddress: json['dropoff_address']?.toString() ?? '',
      estimatedDistanceKm: _toDouble(json['estimated_distance_km']),
      estimatedDurationMinutes: _toInt(json['estimated_duration_minutes']),
      estimatedFare: _toDouble(json['estimated_fare']),
      offeredFare: _toDouble(json['offered_fare']),
      minimumFare: _toDouble(json['minimum_fare']),
      isBidding: json['is_bidding'] != false,
      finalFare: _toDouble(json['final_fare']),
      distanceKm: _toDouble(json['distance_km']),
      durationMinutes: _toInt(json['duration_minutes']),
      paymentMethod:
          PaymentMethod.fromString(json['payment_method']?.toString()),
      promoCodeId: _toInt(json['promo_code_id']),
      discountAmount: _toDouble(json['discount_amount']),
      commissionAmount: _toDouble(json['commission_amount']),
      cancellationReason: json['cancellation_reason']?.toString(),
      driverAssignedAt: _toDateTime(json['driver_assigned_at']),
      driverArrivedAt: _toDateTime(json['driver_arrived_at']),
      startedAt: _toDateTime(json['started_at']),
      completedAt: _toDateTime(json['completed_at']),
      cancelledAt: _toDateTime(json['cancelled_at']),
      expiresAt: _toDateTime(json['expires_at']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      driverName: () {
        final driver = json['driver'] as Map<String, dynamic>?;
        final user = driver?['user'] as Map<String, dynamic>?;
        return user?['name']?.toString() ?? json['driver_name']?.toString();
      }(),
      vehiclePlate: () {
        final driver = json['driver'] as Map<String, dynamic>?;
        final vehicle = driver?['vehicle'] as Map<String, dynamic>?;
        return vehicle?['plate_number']?.toString() ??
            vehicle?['plate']?.toString() ??
            json['vehicle_plate']?.toString();
      }(),
    );
  }

  static RideBidModel rideBidFromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;
    final user = driver?['user'] as Map<String, dynamic>?;
    final vehicle = driver?['vehicle'] as Map<String, dynamic>?;

    String? vehicleDescription;
    if (vehicle != null) {
      final make = vehicle['make']?.toString() ?? '';
      final model = vehicle['model']?.toString() ?? '';
      vehicleDescription = '$make $model'.trim();
      if (vehicleDescription.isEmpty) {
        vehicleDescription = vehicle['plate_number']?.toString();
      }
    }

    return RideBidModel(
      id: _toInt(json['id']) ?? 0,
      rideId: _toInt(json['ride_id']) ?? 0,
      driverId: _toInt(json['driver_id']) ?? 0,
      amount: _toDouble(json['amount']) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      expiresAt: _toDateTime(json['expires_at']),
      driverName: user?['name']?.toString(),
      driverRating: _toDouble(driver?['rating_average']),
      vehicleDescription: vehicleDescription,
      driverAvatar: user?['avatar']?.toString(),
    );
  }

  static List<RideBidModel> rideBidsFromJsonList(dynamic data) {
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(rideBidFromJson)
        .toList();
  }

  static List<RideModel> ridesFromJsonList(dynamic data) {
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(rideFromJson)
        .toList();
  }

  static WalletModel walletFromJson(Map<String, dynamic> json) {
    final transactions = json['transactions'];
    return WalletModel(
      id: _toInt(json['id']) ?? 0,
      userId: _toInt(json['user_id']) ?? 0,
      balance: _toDouble(json['balance']) ?? 0,
      currency: json['currency']?.toString() ?? 'USD',
      transactions: transactions is List
          ? transactions
              .whereType<Map<String, dynamic>>()
              .map(walletTransactionFromJson)
              .toList()
          : const [],
    );
  }

  static WalletTransactionModel walletTransactionFromJson(
    Map<String, dynamic> json,
  ) {
    return WalletTransactionModel(
      id: _toInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? '',
      amount: _toDouble(json['amount']) ?? 0,
      balanceAfter: _toDouble(json['balance_after']) ?? 0,
      description: json['description']?.toString(),
      rideId: _toInt(json['ride_id']),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  static FareEstimateModel fareEstimateFromJson(Map<String, dynamic> json) {
    final fare = json['fare'];
    double baseFare = 0;
    double? discount;
    double? finalFare;

    if (fare is Map<String, dynamic>) {
      // Backend FareCalculatorService returns: fare, discount, subtotal
      baseFare = _toDouble(fare['fare']) ??
          _toDouble(fare['subtotal']) ??
          _toDouble(fare['base_fare']) ??
          _toDouble(fare['total']) ??
          0;
      discount = _toDouble(fare['discount']) ?? _toDouble(fare['discount_amount']);
      finalFare = _toDouble(fare['fare']) ??
          _toDouble(fare['final_fare']) ??
          _toDouble(fare['total']);
    } else {
      baseFare = _toDouble(fare) ?? 0;
      finalFare = baseFare;
    }

    return FareEstimateModel(
      distanceKm: _toDouble(json['distance_km']) ?? 0,
      estimatedDurationMinutes: _toInt(json['estimated_duration_minutes']) ??
          _toInt(json['duration_minutes']) ??
          0,
      fare: finalFare ?? baseFare,
      nearbyDriversCount: _toInt(json['nearby_drivers_count']) ?? 0,
      discountAmount: discount,
      finalFare: finalFare ?? baseFare,
    );
  }

  static WithdrawalModel withdrawalFromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      id: _toInt(json['id']) ?? 0,
      amount: _toDouble(json['amount']) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      bankName: json['bank_name']?.toString(),
      accountNumber: json['account_number']?.toString(),
      accountHolder: json['account_holder']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  static PromoModel promoFromJson(Map<String, dynamic> json) {
    return PromoModel(
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      discountType: json['discount_type']?.toString() ?? 'fixed',
      discountValue: _toDouble(json['discount_value']) ?? 0,
      maxDiscount: _toDouble(json['max_discount']),
      minFare: _toDouble(json['min_fare']),
      isValid: json['valid'] == true || json['is_valid'] == true,
      discountAmount: _toDouble(json['discount_amount']),
    );
  }

  static RatingModel ratingFromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: _toInt(json['id']) ?? 0,
      rideId: _toInt(json['ride_id']) ?? 0,
      raterId: _toInt(json['rater_id']) ?? 0,
      ratedId: _toInt(json['rated_id']) ?? 0,
      score: _toInt(json['score']) ?? 0,
      comment: json['comment']?.toString(),
      createdAt: _toDateTime(json['created_at']),
    );
  }

  static ComplaintModel complaintFromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: _toInt(json['id']) ?? 0,
      userId: _toInt(json['user_id']) ?? 0,
      rideId: _toInt(json['ride_id']),
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      adminResponse: json['admin_response']?.toString(),
      resolvedAt: _toDateTime(json['resolved_at']),
      createdAt: _toDateTime(json['created_at']),
    );
  }
}
