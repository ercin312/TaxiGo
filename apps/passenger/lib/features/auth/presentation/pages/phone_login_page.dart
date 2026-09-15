import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../app/router.dart';
import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';
import '../../../app_mode/application/app_mode_cubit.dart';

/// Social sign-in (Apple / Google).
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  String _role = 'passenger';

  bool get _showApple =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  bool get _showGoogle =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _goAfterAuth(BuildContext context, AuthState state) async {
    if (!isProfileComplete(state.user)) {
      context.go('/profile-setup');
      return;
    }
    final isDriver = state.user?.role == 'driver';
    if (isDriver) {
      await passengerGetIt<AppModeCubit>().switchToDriver(isApproved: true);
      if (context.mounted) context.go('/driver-home');
      return;
    }
    await passengerGetIt<AppModeCubit>().switchToPassenger();
    if (context.mounted) context.go(await resolveHomeRoute());
  }

  void _social(SocialAuthProvider provider) {
    context.read<AuthBloc>().add(
          AuthSocialLoginRequested(
            provider: provider,
            role: _role,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _goAfterAuth(context, state);
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;
        return AuthScaffold(
          title: 'Sign In',
          subtitle: 'Continue with Apple or Google to start riding.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'passenger',
                    label: Text('Passenger'),
                    icon: Icon(Icons.person),
                  ),
                  ButtonSegment(
                    value: 'driver',
                    label: Text('Driver'),
                    icon: Icon(Icons.local_taxi),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: loading
                    ? null
                    : (value) => setState(() => _role = value.first),
              ),
              const SizedBox(height: 28),
              if (_showApple) ...[
                FilledButton.icon(
                  onPressed:
                      loading ? null : () => _social(SocialAuthProvider.apple),
                  icon: const Icon(Icons.apple, size: 26),
                  label: Text(
                    loading ? 'Signing in…' : 'Continue with Apple',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_showGoogle)
                OutlinedButton.icon(
                  onPressed:
                      loading ? null : () => _social(SocialAuthProvider.google),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: Text(
                    loading ? 'Signing in…' : 'Continue with Google',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              if (loading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        );
      },
    );
  }
}
