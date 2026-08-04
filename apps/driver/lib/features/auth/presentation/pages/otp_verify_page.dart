import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../application/driver_auth_bloc.dart';

class OtpVerifyPage extends StatefulWidget {
  const OtpVerifyPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyOtp)),
      body: BlocConsumer<DriverAuthBloc, DriverAuthState>(
        listener: (context, state) {
          if (state is DriverAuthAuthenticated) {
            context.go('/');
          } else if (state is DriverAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is DriverAuthLoading,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${l10n.verifyOtp}: ${widget.phoneNumber}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: InputDecoration(
                        labelText: l10n.otpCode,
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: l10n.confirm,
                      onPressed: () {
                        context.read<DriverAuthBloc>().add(
                              DriverAuthOtpSubmitted(
                                verificationId: widget.verificationId,
                                smsCode: _otpController.text.trim(),
                              ),
                            );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.read<DriverAuthBloc>().add(
                              const DriverAuthResendOtp(),
                            );
                      },
                      child: Text(l10n.resendOtp),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
