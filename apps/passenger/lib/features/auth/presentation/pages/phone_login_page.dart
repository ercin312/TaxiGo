import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../app/router.dart';
import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';
import '../../../app_mode/application/app_mode_cubit.dart';

/// Production login — phone OTP. Social sign-in is disabled on iOS
/// because Sign in with Apple / Google crash on iPadOS 26 review devices.
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _phoneController = TextEditingController(text: '+905550000001');
  final _nameController = TextEditingController(text: 'App Review');
  String _role = 'passenger';

  /// Native Apple/Google auth crashes the process on iPadOS 26
  /// (uncaught in the plugin / Firebase). Phone OTP is the supported path.
  bool get _showApple => false;

  bool get _showGoogle =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _requestOtp(BuildContext context) {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    if (phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number.')),
      );
      return;
    }
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name.')),
      );
      return;
    }
    context.read<AuthBloc>().add(
          AuthOtpRequested(
            phoneNumber: phone,
            name: name,
            role: _role,
          ),
        );
  }

  void _social(SocialAuthProvider provider) {
    context.read<AuthBloc>().add(
          AuthSocialLoginRequested(provider: provider, role: 'passenger'),
        );
  }

  Future<void> _goAfterAuth(BuildContext context, AuthState state) async {
    if (!isProfileComplete(state.user)) {
      context.go('/profile-setup');
      return;
    }
    final isDriver = state.user?.role == 'driver';
    if (isDriver) {
      await passengerGetIt<AppModeCubit>().switchToDriver(isApproved: true);
      // Review / demo drivers land on driver home, not empty KYC.
      if (context.mounted) context.go('/driver-home');
      return;
    }
    await passengerGetIt<AppModeCubit>().switchToPassenger();
    if (context.mounted) context.go(await resolveHomeRoute());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpSent) {
          context.push('/otp', extra: {
            'phone': state.phoneNumber ?? _phoneController.text.trim(),
            'name': state.name ?? _nameController.text.trim(),
            'channel': state.otpChannel,
            // Always forward server debug codes (App Review demo accounts).
            if (state.otpDebugCode != null) 'debugCode': state.otpDebugCode,
            'role': _role,
          });
          return;
        }
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
          subtitle:
              'Sign in with the demo phone number. The OTP code is shown on the next screen — no SMS required.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_showApple) ...[
                FilledButton.icon(
                  onPressed: loading
                      ? null
                      : () => _social(SocialAuthProvider.apple),
                  icon: const Icon(Icons.apple, size: 22),
                  label: const Text('Sign in with Apple'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_showGoogle) ...[
                OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : () => _social(SocialAuthProvider.google),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: AppColors.ink,
                    side: BorderSide(
                      color: AppColors.ink.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Demo accounts (App Review)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Passenger +905550000001 · Driver +905550000002 · OTP 123456',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _requestOtp(context),
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
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
                onSelectionChanged: (value) {
                  setState(() {
                    _role = value.first;
                    if (_role == 'driver') {
                      _phoneController.text = '+905550000002';
                      _nameController.text = 'App Review Driver';
                    } else {
                      _phoneController.text = '+905550000001';
                      _nameController.text = 'App Review';
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.sendOtp,
                icon: Icons.sms_outlined,
                isLoading: loading,
                onPressed: () => _requestOtp(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
