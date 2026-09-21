import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../app_mode/application/app_mode_cubit.dart';
import '../../../driver_profile/application/driver_profile_cubit.dart';
import '../../../shell/presentation/widgets/menu_row_tile.dart';
import '../../../shell/presentation/widgets/section_header.dart';
import '../../../shell/presentation/widgets/soft_card.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int _tripCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<DriverProfileCubit>().load();
    _loadTripCount();
  }

  Future<void> _loadTripCount() async {
    // Best-effort from history when available via repository later.
    if (!mounted) return;
    setState(() => _tripCount = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthBloc>().state.user;
    final driverState = context.watch<DriverProfileCubit>().state;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 100 + bottomInset),
          children: [
            SoftCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.mist,
                    child: Text(
                      (user?.name.isNotEmpty ?? false)
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? l10n.profile,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 4),
                            Text('0 · ${l10n.totalTrips(_tripCount)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/complaints'),
                    icon: const Icon(Icons.help_outline, size: 16),
                    label: Text(l10n.help),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: l10n.accountSection,
              subtitle: l10n.accountSectionHint,
            ),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  MenuRowTile(
                    icon: Icons.person_outline_rounded,
                    title: l10n.personalInfo,
                    subtitle: user?.phone ?? user?.email,
                    iconBackground: const Color(0xFFDCEBFF),
                    onTap: () => context.push('/profile-edit'),
                  ),
                  const Divider(height: 1),
                  MenuRowTile(
                    icon: Icons.favorite_border_rounded,
                    title: l10n.favoriteLocations,
                    subtitle: l10n.favoriteLocationsHint,
                    iconBackground: const Color(0xFFFFE4EC),
                    onTap: () => context.push('/favorites'),
                  ),
                  const Divider(height: 1),
                  MenuRowTile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.wallet,
                    iconBackground: const Color(0xFFE8F5E9),
                    onTap: () => context.push('/wallet'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: l10n.activitySection,
              subtitle: l10n.activitySectionHint,
            ),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  MenuRowTile(
                    icon: Icons.history_rounded,
                    title: l10n.tripHistory,
                    subtitle: l10n.tripHistoryHint,
                    iconBackground: const Color(0xFFDDF5F2),
                    onTap: () => context.go('/trips'),
                  ),
                  const Divider(height: 1),
                  MenuRowTile(
                    icon: Icons.event_available_outlined,
                    title: l10n.upcomingTrips,
                    subtitle: l10n.upcomingTripsHint,
                    iconBackground: const Color(0xFFEDE7FF),
                    onTap: () => context.go('/trips'),
                  ),
                  const Divider(height: 1),
                  MenuRowTile(
                    icon: Icons.local_offer_outlined,
                    title: l10n.promos,
                    iconBackground: const Color(0xFFFFF3D6),
                    onTap: () => context.push('/promos'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: l10n.settingsSection,
              subtitle: l10n.settingsSectionHint,
            ),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  MenuRowTile(
                    icon: Icons.language_rounded,
                    title: l10n.selectLanguage,
                    subtitle: l10n.languageSubtitle,
                    iconBackground: const Color(0xFFDCEBFF),
                    onTap: () => context.push('/language'),
                  ),
                  const Divider(height: 1),
                  MenuRowTile(
                    icon: Icons.report_problem_outlined,
                    title: l10n.complaints,
                    iconBackground: const Color(0xFFFFE8D6),
                    onTap: () => context.push('/complaints'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SoftCard(
              padding: EdgeInsets.zero,
              child: _DriverSection(driverState: driverState),
            ),
            const SizedBox(height: 18),
            SoftCard(
              padding: EdgeInsets.zero,
              child: MenuRowTile(
                icon: Icons.logout_rounded,
                title: l10n.logout,
                destructive: true,
                onTap: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                  context.go('/login');
                },
              ),
            ),
          ],
        ),
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
      return MenuRowTile(
        icon: Icons.local_taxi,
        title: l10n.becomeDriver,
        subtitle: l10n.driverMode,
        iconBackground: const Color(0xFFFFF3D6),
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
          MenuRowTile(
            icon: Icons.hourglass_top,
            title: l10n.driverApplicationPending,
            subtitle: l10n.viewApplicationStatus,
            onTap: () => context.push('/driver/pending'),
          )
        else if (driver.approvalStatus == DriverApprovalStatus.rejected ||
            driver.approvalStatus == DriverApprovalStatus.banned)
          MenuRowTile(
            icon: Icons.cancel_outlined,
            title: l10n.driverApplicationRejected,
            subtitle: driver.rejectionReason,
            onTap: () => context.push('/driver/pending'),
          )
        else if (driver.isApproved) ...[
          MenuRowTile(
            icon: Icons.drive_eta,
            title: l10n.switchToDriverMode,
            subtitle: l10n.driverMode,
            onTap: () async {
              await context
                  .read<AppModeCubit>()
                  .switchToDriver(isApproved: true);
              if (context.mounted) context.go('/driver-home');
            },
          ),
          const Divider(height: 1),
          MenuRowTile(
            icon: Icons.payments,
            title: l10n.earnings,
            onTap: () => context.push('/driver/earnings'),
          ),
        ],
      ],
    );
  }
}
