import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../auth/application/driver_auth_bloc.dart';
import '../../../kyc/application/kyc_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<DriverAuthBloc>().add(const DriverAuthCheckRequested());
  }

  Future<void> _routeAuthenticated() async {
    final kycBloc = context.read<KycBloc>();
    kycBloc.add(const KycCheckStatus());

    await for (final state in kycBloc.stream) {
      if (!mounted) return;
      if (state is KycNeedsRegistration || state is KycFailure) {
        context.go('/register');
        return;
      }
      if (state is KycPendingApproval || state is KycRejected) {
        context.go('/pending');
        return;
      }
      if (state is KycApproved) {
        context.go('/home');
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<DriverAuthBloc, DriverAuthState>(
      listener: (context, state) {
        if (state is DriverAuthUnauthenticated) {
          context.go('/login');
        } else if (state is DriverAuthAuthenticated) {
          _routeAuthenticated();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_taxi, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.driverMode,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
