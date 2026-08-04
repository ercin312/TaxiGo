import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxigo_core/taxigo_core.dart';

void main() {
  test('RideStatus maps backend values', () {
    expect(RideStatus.fromString('driver_arriving'), RideStatus.driverArriving);
    expect(RideStatus.driverArriving.displayKey, 'rideStatusDriverArriving');
    expect(RideStatus.completed.isTerminal, isTrue);
    expect(RideStatus.pending.isActive, isTrue);
  });

  test('SupportedLocales includes all five languages', () {
    expect(SupportedLocales.all, hasLength(5));
    expect(SupportedLocales.findByCode('tr'), isNotNull);
    expect(SupportedLocales.findByCode('ar')?.languageCode, 'ar');
  });

  test('AppConstants exposes API base URL', () {
    expect(AppConstants.baseUrl, isNotEmpty);
    expect(AppColors.primary, const Color(0xFF001CAD));
  });
}
