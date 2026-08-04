import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../app/router.dart';
import '../../../../core/app_helpers.dart';

/// Login — name/phone form + Google / Apple social.
class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _phoneController = TextEditingController(text: '+905');
  final _nameController = TextEditingController();
  String _role = 'passenger';

  bool get _showApple =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim();
    if (phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir telefon numarası girin.')),
      );
      return;
    }
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen adınızı girin.')),
      );
      return;
    }
    context.read<AuthBloc>().add(
          AuthDemoLoginRequested(
            phoneNumber: phone,
            name: name,
            role: _role,
          ),
        );
  }

  void _social(SocialAuthProvider provider) {
    context.read<AuthBloc>().add(
          AuthSocialLoginRequested(provider: provider, role: _role),
        );
  }

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
            // KYC gate — never open driver home until approved.
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
        final loading = state.status == AuthStatus.loading;
        return AuthScaffold(
          title: 'Giriş Yap',
          subtitle: 'Google veya Apple ile devam edin; ya da ad ve telefon ile giriş yapın.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Hızlı üyelik',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: loading
                    ? null
                    : () => _social(SocialAuthProvider.google),
                icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                label: const Text('Google ile devam et'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: AppColors.ink,
                  side: BorderSide(
                    color: AppColors.ink.withValues(alpha: 0.2),
                  ),
                ),
              ),
              if (_showApple) ...[
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: loading
                      ? null
                      : () => _social(SocialAuthProvider.apple),
                  icon: const Icon(Icons.apple, size: 22),
                  label: const Text('Apple ile devam et'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
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
                onSubmitted: (_) => _login(context),
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
                    label: Text('Yolcu'),
                    icon: Icon(Icons.person),
                  ),
                  ButtonSegment(
                    value: 'driver',
                    label: Text('Sürücü'),
                    icon: Icon(Icons.local_taxi),
                  ),
                ],
                selected: {_role},
                onSelectionChanged: (value) {
                  setState(() => _role = value.first);
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Giriş Yap',
                icon: Icons.arrow_forward_rounded,
                isLoading: loading,
                onPressed: () => _login(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
