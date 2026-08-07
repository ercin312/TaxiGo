import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../app/router.dart';
import '../../../../core/app_helpers.dart';

class OtpVerifyPage extends StatefulWidget {
  const OtpVerifyPage({
    required this.phone,
    this.name,
    this.channel,
    this.debugCode,
    this.role = 'passenger',
    super.key,
  });

  final String phone;
  final String? name;
  final String? channel;
  final String? debugCode;
  final String role;

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          if (!isProfileComplete(state.user)) {
            context.go('/profile-setup');
            return;
          }
          final isDriver = state.user?.role == 'driver';
          if (isDriver) {
            context.go('/driver/register');
            return;
          }
          resolveHomeRoute().then((route) {
            if (context.mounted) context.go(route);
          });
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final channel = widget.channel ?? state.otpChannel ?? 'sms';
        final debug = widget.debugCode ?? state.otpDebugCode;
        final showDebug =
            kDebugMode && AppConstants.allowDemoMode && debug != null;

        return AuthScaffold(
          title: l10n.verifyOtpTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.verifyOtpSubtitle(widget.phone),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kanal: $channel',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (showDebug) ...[
                const SizedBox(height: 8),
                Text(
                  'Geliştirme kodu: $debug',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              const SizedBox(height: 24),
              PinCodeTextField(
                appContext: context,
                length: 6,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 48,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  activeColor: AppColors.primary,
                  selectedColor: AppColors.primary,
                  inactiveColor: Colors.black26,
                ),
                enableActiveFill: true,
                onChanged: (value) => _code = value,
                onCompleted: (value) {
                  _code = value;
                  _submit(context);
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.verifyOtp,
                isLoading: state.status == AuthStatus.loading,
                onPressed: () => _submit(context),
              ),
              TextButton(
                onPressed: state.status == AuthStatus.loading
                    ? null
                    : () {
                        context.read<AuthBloc>().add(
                              AuthOtpRequested(
                                phoneNumber: widget.phone,
                                name: widget.name,
                                role: widget.role,
                              ),
                            );
                      },
                child: Text(l10n.resendOtp),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    if (_code.length < 4) return;
    context.read<AuthBloc>().add(
          AuthOtpVerifyRequested(
            phoneNumber: widget.phone,
            code: _code,
            name: widget.name,
            role: widget.role,
          ),
        );
  }
}
