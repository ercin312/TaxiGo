class RideReceiptModel {
  const RideReceiptModel({
    required this.receiptNumber,
    required this.companyName,
    required this.rideReference,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.currency,
    required this.total,
    this.issuedAt,
    this.completedAt,
    this.companyAddress,
    this.companyTaxId,
    this.companyEmail,
    this.passengerName,
    this.driverName,
    this.vehiclePlate,
    this.vehicleModel,
    this.paymentMethod,
    this.distanceKm,
    this.durationMinutes,
    this.subtotal,
    this.discount,
    this.promoCode,
    this.productMode,
    this.notes = const [],
  });

  final String receiptNumber;
  final String companyName;
  final String? companyAddress;
  final String? companyTaxId;
  final String? companyEmail;
  final String rideReference;
  final String pickupAddress;
  final String dropoffAddress;
  final DateTime? issuedAt;
  final DateTime? completedAt;
  final String? passengerName;
  final String? driverName;
  final String? vehiclePlate;
  final String? vehicleModel;
  final String? paymentMethod;
  final String? productMode;
  final double? distanceKm;
  final int? durationMinutes;
  final String currency;
  final double total;
  final double? subtotal;
  final double? discount;
  final String? promoCode;
  final List<String> notes;

  factory RideReceiptModel.fromJson(Map<String, dynamic> json) {
    final company = json['company'] is Map
        ? Map<String, dynamic>.from(json['company'] as Map)
        : <String, dynamic>{};
    final ride = json['ride'] is Map
        ? Map<String, dynamic>.from(json['ride'] as Map)
        : <String, dynamic>{};
    final passenger = json['passenger'] is Map
        ? Map<String, dynamic>.from(json['passenger'] as Map)
        : <String, dynamic>{};
    final driver = json['driver'] is Map
        ? Map<String, dynamic>.from(json['driver'] as Map)
        : <String, dynamic>{};
    final amounts = json['amounts'] is Map
        ? Map<String, dynamic>.from(json['amounts'] as Map)
        : <String, dynamic>{};
    final notesRaw = json['notes'];

    return RideReceiptModel(
      receiptNumber: (json['receipt_number'] ?? '').toString(),
      issuedAt: json['issued_at'] != null
          ? DateTime.tryParse(json['issued_at'].toString())
          : null,
      companyName: (company['name'] ?? 'TaxiGo').toString(),
      companyAddress: company['address']?.toString(),
      companyTaxId: company['tax_id']?.toString(),
      companyEmail: company['email']?.toString(),
      rideReference: (ride['reference'] ?? '').toString(),
      completedAt: ride['completed_at'] != null
          ? DateTime.tryParse(ride['completed_at'].toString())
          : null,
      pickupAddress: (ride['pickup_address'] ?? '').toString(),
      dropoffAddress: (ride['dropoff_address'] ?? '').toString(),
      distanceKm: (ride['distance_km'] as num?)?.toDouble(),
      durationMinutes: (ride['duration_minutes'] as num?)?.toInt(),
      paymentMethod: ride['payment_method']?.toString(),
      productMode: ride['product_mode']?.toString(),
      passengerName: passenger['name']?.toString(),
      driverName: driver['name']?.toString(),
      vehiclePlate: driver['vehicle_plate']?.toString(),
      vehicleModel: driver['vehicle_model']?.toString(),
      currency: (amounts['currency'] ?? 'EUR').toString(),
      total: (amounts['total'] as num?)?.toDouble() ?? 0,
      subtotal: (amounts['subtotal'] as num?)?.toDouble(),
      discount: (amounts['discount'] as num?)?.toDouble(),
      promoCode: amounts['promo_code']?.toString(),
      notes: notesRaw is List
          ? notesRaw.map((e) => e.toString()).toList()
          : const [],
    );
  }

  String toShareText() {
    final buf = StringBuffer()
      ..writeln(companyName)
      ..writeln(receiptNumber)
      ..writeln('Trip: $rideReference')
      ..writeln('From: $pickupAddress')
      ..writeln('To: $dropoffAddress');
    if (completedAt != null) {
      buf.writeln('Completed: ${completedAt!.toLocal()}');
    }
    if (driverName != null) buf.writeln('Driver: $driverName');
    if (vehiclePlate != null) buf.writeln('Vehicle: $vehiclePlate');
    if (discount != null && discount! > 0) {
      buf.writeln('Discount: -${discount!.toStringAsFixed(2)} $currency');
    }
    buf.writeln('Total: ${total.toStringAsFixed(2)} $currency');
    buf.writeln('Payment: ${paymentMethod ?? 'cash'}');
    return buf.toString();
  }
}
