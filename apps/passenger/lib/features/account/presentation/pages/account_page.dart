import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../app_mode/application/app_mode_cubit.dart';
import '../../../driver_profile/application/driver_profile_cubit.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    context.read<DriverProfileCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthBloc>().state.user;
    final driverState = context.watch<DriverProfileCubit>().state;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.account)),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24 + bottomInset),
        children: [
          UserAccountsDrawerHeader(
            margin: EdgeInsets.zero,
            accountName: Text(user?.name ?? l10n.profile),
            accountEmail: Text(user?.phone ?? user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.name.isNotEmpty ?? false)
                    ? user!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 28,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            decoration: const BoxDecoration(color: AppColors.primary),
          ),
          _DriverSection(driverState: driverState),
          const Divider(),
          _MenuTile(
            icon: Icons.person,
            title: l10n.editProfile,
            onTap: () => context.push('/profile-edit'),
          ),
          _MenuTile(
            icon: Icons.account_balance_wallet,
            title: l10n.wallet,
            onTap: () => context.push('/wallet'),
          ),
          _MenuTile(
            icon: Icons.history,
            title: l10n.tripHistory,
            onTap: () => context.push('/trips'),
          ),
          _MenuTile(
            icon: Icons.local_offer,
            title: l10n.promos,
            onTap: () => context.push('/promos'),
          ),
          _MenuTile(
            icon: Icons.report_problem,
            title: l10n.complaints,
            onTap: () => context.push('/complaints'),
          ),
          _MenuTile(
            icon: Icons.language,
            title: l10n.selectLanguage,
            onTap: () => context.push('/language'),
          ),
          const Divider(),
          _MenuTile(
            icon: Icons.logout,
            title: l10n.logout,
            onTap: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _DriverSection extends StatelessWidget {
  const _DriverSection({required this.driverState});

  final DriverProfileState driverState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (driverState is DriverProfileLoading ||
        driverState is DriverProfileInitial) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (driverState is DriverProfileNotRegistered) {
      return _MenuTile(
        icon: Icons.local_taxi,
        title: l10n.becomeDriver,
        subtitle: l10n.driverMode,
        onTap: () => context.push('/driver/register'),
      );
    }

    if (driverState is DriverProfileFailure) {
      return ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: Text((driverState as DriverProfileFailure).message),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<DriverProfileCubit>().load(),
        ),
      );
    }

    final driver = (driverState as DriverProfileLoaded).driver;

    return Column(
      children: [
        if (driver.approvalStatus == DriverApprovalStatus.pending)
          _MenuTile(
            icon: Icons.hourglass_top,
            title: l10n.driverApplicationPending,
            subtitle: l10n.viewApplicationStatus,
            onTap: () => context.push('/driver/pending'),
          )
        else if (driver.approvalStatus == DriverApprovalStatus.rejected ||
            driver.approvalStatus == DriverApprovalStatus.banned)
          _MenuTile(
            icon: Icons.cancel_outlined,
            title: l10n.driverApplicationRejected,
            subtitle: driver.rejectionReason,
            onTap: () => context.push('/driver/pending'),
          )
        else if (driver.isApproved) ...[
          _MenuTile(
            icon: Icons.drive_eta,
            title: l10n.switchToDriverMode,
            subtitle: 'Taksi / sürücü ekranı',
            onTap: () async {
              await context
                  .read<AppModeCubit>()
                  .switchToDriver(isApproved: true);
              if (context.mounted) context.go('/driver-home');
            },
          ),
          _MenuTile(
            icon: Icons.payments,
            title: l10n.earnings,
            onTap: () => context.push('/driver/earnings'),
          ),
        ],
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
