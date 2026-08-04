import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../application/account_bloc.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _populated = false;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(const AccountLoadRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.edit)),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountLoaded && !_populated) {
            _nameController.text = state.user.name;
            _emailController.text = state.user.email ?? '';
            _populated = true;
          }
        },
        builder: (context, state) {
          final isSaving = state is AccountLoaded && state.isSaving;

          return LoadingOverlay(
            isLoading: state is AccountLoading || isSaving,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: l10n.profile),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: l10n.save,
                    onPressed: () {
                      context.read<AccountBloc>().add(
                            AccountUpdateProfile(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                            ),
                          );
                      context.pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
