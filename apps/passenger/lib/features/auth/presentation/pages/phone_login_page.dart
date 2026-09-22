import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../app/router.dart';
import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';
import '../../../app_mode/application/app_mode_cubit.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'passenger';

  bool get _showGoogle =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get _showApple =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn({
    required String phone,
    required String password,
    required String role,
  }) {
    final trimmedPhone = phone.trim();
    final trimmedPassword = password.trim();
    if (trimmedPhone.isEmpty || trimmedPassword.isEmpty) return;

    context.read<AuthBloc>().add(
          AuthReviewLoginRequested(
            phoneNumber: trimmedPhone,
            password: trimmedPassword,
            name: role == 'driver' ? 'Driver' : 'Passenger',
            role: role,
          ),
        );
  }

  Future<void> _goAfterAuth(BuildContext context, AuthState state) async {
    if (state.user?.isAdmin == true) {
      if (context.mounted) context.go('/admin');
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          title: l10n.signIn,
          subtitle: l10n.loginSubtitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '${l10n.phoneNumber} / Admin',
                  hintText: l10n.phoneNumber,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!loading) {
                    _signIn(
                      phone: _usernameController.text,
                      password: _passwordController.text,
                      role: _role,
                    );
                  }
                },
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'passenger',
                    label: Text(l10n.rolePassenger),
                    icon: const Icon(Icons.person),
                  ),
                  ButtonSegment(
                    value: 'driver',
                    label: Text(l10n.roleDriver),
                    icon: const Icon(Icons.local_taxi),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: loading
                    ? null
                    : (value) => setState(() => _role = value.first),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: l10n.signIn,
                icon: Icons.login_rounded,
                isLoading: loading,
                onPressed: () => _signIn(
                  phone: _usernameController.text,
                  password: _passwordController.text,
                  role: _role,
                ),
              ),
              if (_showApple) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : () => context.read<AuthBloc>().add(
                            AuthSocialLoginRequested(
                              provider: SocialAuthProvider.apple,
                              role: _role,
                            ),
                          ),
                  icon: const Icon(Icons.apple, size: 22),
                  label: Text(l10n.continueWithApple),
                ),
              ],
              if (_showGoogle) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : () => context.read<AuthBloc>().add(
                            AuthSocialLoginRequested(
                              provider: SocialAuthProvider.google,
                              role: _role,
                            ),
                          ),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: Text(l10n.continueWithGoogle),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
