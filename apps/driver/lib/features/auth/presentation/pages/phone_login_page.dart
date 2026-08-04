import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../application/driver_auth_bloc.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.signIn),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => context.push('/language'),
          ),
        ],
      ),
      body: BlocConsumer<DriverAuthBloc, DriverAuthState>(
        listener: (context, state) {
          if (state is DriverAuthOtpSent) {
            context.push(
              '/otp',
              extra: {
                'verificationId': state.verificationId,
                'phoneNumber': state.phoneNumber,
              },
            );
          } else if (state is DriverAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is DriverAuthAuthenticated) {
            context.go('/');
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is DriverAuthLoading,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.local_taxi,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.loginWelcome,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          prefixIcon: const Icon(Icons.phone),
                          hintText: l10n.enterPhone,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length < 10) {
                            return l10n.enterPhone;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: l10n.continueButton,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<DriverAuthBloc>().add(
                                  DriverAuthPhoneSubmitted(
                                    phoneNumber: _phoneController.text.trim(),
                                  ),
                                );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
