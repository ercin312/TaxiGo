import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:taxigo_core/taxigo_core.dart' as core;

import '../di/locator.dart';
import '../features/account/application/account_bloc.dart';
import '../features/auth/application/driver_auth_bloc.dart';
import '../features/kyc/application/kyc_bloc.dart';
import 'router.dart';

class TaxiGoDriverApp extends StatelessWidget {
  const TaxiGoDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<core.LanguageBloc>()..add(const core.LoadLanguage()),
        ),
        BlocProvider(create: (_) => getIt<DriverAuthBloc>()),
        BlocProvider(create: (_) => getIt<KycBloc>()),
        BlocProvider(create: (_) => getIt<AccountBloc>()),
      ],
      child: BlocBuilder<core.LanguageBloc, core.LanguageState>(
        builder: (context, languageState) {
          return MaterialApp.router(
            title: 'TaxiGo Driver',
            debugShowCheckedModeBanner: false,
            theme: core.AppThemes.light,
            darkTheme: core.AppThemes.dark,
            themeMode: ThemeMode.system,
            locale: languageState.locale,
            supportedLocales: core.SupportedLocales.locales,
            localizationsDelegates: const [
              core.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
