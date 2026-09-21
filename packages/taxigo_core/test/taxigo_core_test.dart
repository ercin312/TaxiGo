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

  test('SupportedLocales includes Montenegrin and all languages', () {
    expect(SupportedLocales.all, hasLength(5));
    expect(SupportedLocales.findByCode('tr'), isNotNull);
    expect(SupportedLocales.findByCode('cnr')?.languageCode, 'cnr');
    expect(SupportedLocales.findByCode('xh'), isNull);
    expect(SupportedLocales.findByCode('ar')?.languageCode, 'ar');
  });

  test('AppConstants exposes API base URL', () {
    expect(AppConstants.baseUrl, isNotEmpty);
    expect(AppColors.primary, const Color(0xFF132A4A));
  });

  testWidgets('every supported locale loads distinct UI strings', (tester) async {
    final expected = <String, Map<String, String>>{
      'tr': {
        'selectLanguage': 'Dil Seçin',
        'homeTitle': 'Nereye?',
        'bookRide': 'Yolculuk Rezerve Et',
        'wallet': 'Cüzdan',
      },
      'en': {
        'selectLanguage': 'Select Language',
        'homeTitle': 'Where to?',
        'bookRide': 'Book Ride',
        'wallet': 'Wallet',
      },
      'cnr': {
        'selectLanguage': 'Izaberite jezik',
        'homeTitle': 'Kuda?',
        'bookRide': 'Naruči vožnju',
        'wallet': 'Novčanik',
      },
      'ru': {
        'selectLanguage': 'Выберите язык',
        'homeTitle': 'Куда?',
        'bookRide': 'Заказать поездку',
        'wallet': 'Кошелек',
      },
      'ar': {
        'selectLanguage': 'اختر اللغة',
        'homeTitle': 'إلى أين؟',
        'bookRide': 'احجز رحلة',
        'wallet': 'المحفظة',
      },
    };

    for (final entry in SupportedLocales.all) {
      final code = entry.locale.languageCode;
      late AppLocalizations l10n;

      await tester.pumpWidget(
        MaterialApp(
          locale: entry.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: TaxiGoLocalization.delegates,
          home: Builder(
            builder: (context) {
              l10n = AppLocalizations.of(context)!;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(l10n.localeName, contains(code), reason: 'localeName for $code');
      expect(l10n.appName, 'TaxiGo', reason: 'appName for $code');
      expect(l10n.selectLanguage, isNotEmpty, reason: 'selectLanguage for $code');
      expect(l10n.offerYourFare, isNotEmpty, reason: 'offerYourFare for $code');
      expect(l10n.otpInAppTitle, isNotEmpty, reason: 'otpInAppTitle for $code');
      expect(l10n.secondsLeft(9), isNotEmpty, reason: 'secondsLeft for $code');
      expect(l10n.nearbyDrivers(3), isNotEmpty, reason: 'nearbyDrivers for $code');
      expect(
        l10n.verifyOtpSubtitle('+382'),
        isNotEmpty,
        reason: 'verifyOtpSubtitle for $code',
      );

      final samples = expected[code]!;
      expect(l10n.selectLanguage, samples['selectLanguage'], reason: code);
      expect(l10n.homeTitle, samples['homeTitle'], reason: code);
      expect(l10n.bookRide, samples['bookRide'], reason: code);
      expect(l10n.wallet, samples['wallet'], reason: code);

      // RTL only for Arabic.
      expect(entry.isRtl, code == 'ar', reason: 'RTL flag for $code');
    }

    // Picker registry matches generated AppLocalizations locales.
    final supportedCodes = AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .toSet();
    for (final entry in SupportedLocales.all) {
      expect(
        supportedCodes,
        contains(entry.locale.languageCode),
        reason: '${entry.locale.languageCode} missing from AppLocalizations',
      );
    }
  });
}
