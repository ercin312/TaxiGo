import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../app/router.dart';
import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';
import '../../../app_mode/application/app_mode_cubit.dart';

/// App Review–friendly login: username/password + one-tap demo buttons.
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  static const _reviewPassengerPhone = '+905550000001';
  static const _reviewDriverPhone = '+905550000002';
  static const _reviewPassword = '123456';

  final _usernameController =
      TextEditingController(text: _reviewPassengerPhone);
  final _passwordController = TextEditingController(text: _reviewPassword);
  String _role = 'passenger';

  bool get _showGoogle =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

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
    String? name,
  }) {
    context.read<AuthBloc>().add(
          AuthReviewLoginRequested(
            phoneNumber: phone.trim(),
            password: password.trim(),
            name: name ??
                (role == 'driver'
                    ? 'App Review Driver'
                    : 'App Review Passenger'),
            role: role,
          ),
        );
  }

  void _oneTapPassenger() {
    setState(() {
      _role = 'passenger';
      _usernameController.text = _reviewPassengerPhone;
      _passwordController.text = _reviewPassword;
    });
    _signIn(
      phone: _reviewPassengerPhone,
      password: _reviewPassword,
      role: 'passenger',
      name: 'App Review Passenger',
    );
  }

  void _oneTapDriver() {
    setState(() {
      _role = 'driver';
      _usernameController.text = _reviewDriverPhone;
      _passwordController.text = _reviewPassword;
    });
    _signIn(
      phone: _reviewDriverPhone,
      password: _reviewPassword,
      role: 'driver',
      name: 'App Review Driver',
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
      if (context.mounted) context.go('/driver-home');
      return;
    }
    await passengerGetIt<AppModeCubit>().switchToPassenger();
    if (context.mounted) context.go(await resolveHomeRoute());
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
          subtitle:
              'App Review: use the one-tap buttons, or username + password below.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Demo credentials\n'
                  'Passenger username: +905550000001\n'
                  'Driver username: +905550000002\n'
                  'Password (both): 123456',
                  style: TextStyle(height: 1.45, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: loading ? null : _oneTapPassenger,
                icon: const Icon(Icons.person),
                label: const Text('App Review — Passenger'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: loading ? null : _oneTapDriver,
                icon: const Icon(Icons.local_taxi),
                label: const Text('App Review — Driver'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Username (phone)',
                  prefixIcon: Icon(Icons.person_outline_rounded),
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
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
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
                onSelectionChanged: loading
                    ? null
                    : (value) {
                        setState(() {
                          _role = value.first;
                          if (_role == 'driver') {
                            _usernameController.text = _reviewDriverPhone;
                          } else {
                            _usernameController.text = _reviewPassengerPhone;
                          }
                          _passwordController.text = _reviewPassword;
                        });
                      },
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Sign In',
                icon: Icons.login_rounded,
                isLoading: loading,
                onPressed: () => _signIn(
                  phone: _usernameController.text,
                  password: _passwordController.text,
                  role: _role,
                ),
              ),
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
                  label: const Text('Continue with Google'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
