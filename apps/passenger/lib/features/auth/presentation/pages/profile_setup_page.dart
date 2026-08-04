import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../app/router.dart';
import '../../../../di/locator.dart';
import '../../application/auth_bloc.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => PassengerAuthBloc(
        userRepository: passengerGetIt<UserRepository>(),
      ),
      child: AuthScaffold(
        title: l10n.profileSetupTitle,
        subtitle: 'Hesabınızı tamamlayın ve yolculuğa başlayın.',
        child: BlocConsumer<PassengerAuthBloc, PassengerAuthState>(
          listener: (context, state) {
            if (state is PassengerAuthSuccess) {
              context.read<AuthBloc>().add(const AuthCheckRequested());
              resolveHomeRoute().then((route) {
                if (context.mounted) context.go(route);
              });
            } else if (state is PassengerAuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  label: l10n.continueButton,
                  isLoading: state is PassengerAuthLoading,
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) return;
                    context.read<PassengerAuthBloc>().add(
                          PassengerProfileSetupSubmitted(
                            name: name,
                            email: _emailController.text.trim().isEmpty
                                ? null
                                : _emailController.text.trim(),
                          ),
                        );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
