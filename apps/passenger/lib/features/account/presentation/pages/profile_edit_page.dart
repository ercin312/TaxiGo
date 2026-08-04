import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final result = await passengerGetIt<UserRepository>().updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      ),
      (user) {
        context.read<AuthBloc>().add(const AuthCheckRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil güncellendi')),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.fullName),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: l10n.email),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: l10n.phoneNumber),
            ),
            const Spacer(),
            PrimaryButton(
              label: l10n.save,
              isLoading: _loading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
