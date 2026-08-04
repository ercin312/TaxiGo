import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../di/locator.dart';
import '../features/app_mode/application/app_mode_cubit.dart';
import '../features/driver_profile/application/driver_profile_cubit.dart';
import 'router.dart';

class TaxiGoApp extends StatefulWidget {
  const TaxiGoApp({super.key});

  @override
  State<TaxiGoApp> createState() => _TaxiGoAppState();
}

class _TaxiGoAppState extends State<TaxiGoApp> {
  late final AuthBloc _authBloc =
      passengerGetIt<AuthBloc>()..add(const AuthCheckRequested());
  late final GoRouter _router = createAppRouter(_authBloc);

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              passengerGetIt<LanguageBloc>()..add(const LoadLanguage()),
        ),
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: passengerGetIt<AppModeCubit>()),
        BlocProvider.value(value: passengerGetIt<DriverProfileCubit>()),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppThemes.light,
            darkTheme: AppThemes.light,
            themeMode: ThemeMode.light,
            locale: languageState.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
