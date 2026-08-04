import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../di/locator.dart';
import '../../../auth/application/driver_auth_bloc.dart';
import '../../application/account_bloc.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  DriverModel? _driver;

  @override
  void initState() {
    super.initState();
    context.read<AccountBloc>().add(const AccountLoadRequested());
    _loadDriver();
  }

  Future<void> _loadDriver() async {
    final result = await getIt<DriverRepository>().getProfile();
    if (mounted) {
      setState(() {
        _driver = result.fold((_) => null, (d) => d);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AccountFailure) {
            return ErrorView(
              message: state.message,
              onRetry: () {
                context.read<AccountBloc>().add(const AccountLoadRequested());
              },
            );
          }

          if (state is! AccountLoaded) {
            return const SizedBox.shrink();
          }

          final user = state.user;

          return ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                accountName: Text(user.name),
                accountEmail: Text(user.phone ?? user.email ?? ''),
              ),
              if (_driver != null) ...[
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: Text(l10n.approvalApproved),
                  trailing: Chip(label: Text(_driver!.approvalStatus.name)),
                ),
                if (_driver!.vehicleMake != null)
                  ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: Text(l10n.driverMode),
                    subtitle: Text(
                      '${_driver!.vehicleMake} ${_driver!.vehicleModel} (${_driver!.vehiclePlate})',
                    ),
                  ),
              ],
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(l10n.edit),
                onTap: () => context.push('/profile-edit'),
              ),
              ListTile(
                leading: const Icon(Icons.payments),
                title: Text(l10n.earnings),
                onTap: () => context.push('/earnings'),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(l10n.rideHistory),
                onTap: () => context.push('/history'),
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: Text(l10n.rateRide),
                onTap: () => context.push('/ratings'),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                onTap: () => context.push('/language'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  l10n.signOut,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  context.read<DriverAuthBloc>().add(
                        const DriverAuthLogoutRequested(),
                      );
                  context.go('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
