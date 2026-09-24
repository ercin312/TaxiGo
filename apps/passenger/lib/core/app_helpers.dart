import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../di/locator.dart';
import '../features/app_mode/application/app_mode_cubit.dart';

const pendingIntendedRoleKey = 'pending_intended_role';

bool isProfileComplete(UserModel? user) {
  if (user == null) return false;
  if (user.isAdmin) return true;
  final name = user.name.trim();
  if (name.isEmpty) return false;
  if (name.toLowerCase() == 'user') return false;
  if (RegExp(r'^user\s', caseSensitive: false).hasMatch(name)) return false;
  return true;
}

/// Social (Apple/Google) accounts must provide a phone before using the app.
bool needsPhoneNumber(UserModel? user) {
  if (user == null || user.isAdmin) return false;
  final phone = user.phone?.trim() ?? '';
  return phone.length < 8;
}

bool isMissingDriverProfileError(String message) {
  final m = message.toLowerCase();
  return m.contains('not found') ||
      m.contains('bulunamad') ||
      m.contains('no driver') ||
      m.contains('404');
}

String? takePendingIntendedRole() {
  final prefs = passengerGetIt<SharedPreferences>();
  final role = prefs.getString(pendingIntendedRoleKey);
  if (role != null) {
    prefs.remove(pendingIntendedRoleKey);
  }
  return role;
}

String? peekPendingIntendedRole() {
  return passengerGetIt<SharedPreferences>().getString(pendingIntendedRoleKey);
}

/// Driver entry: registration → pending → home (approved only).
Future<String> resolveDriverEntryRoute() async {
  final result = await passengerGetIt<DriverRepository>().getProfile();
  return result.fold(
    (_) => '/driver/register',
    (driver) {
      if (driver.isApproved) {
        return '/driver-home';
      }
      if (driver.approvalStatus == DriverApprovalStatus.pending) {
        return '/driver/pending';
      }
      return '/driver/register';
    },
  );
}

/// Shared post-auth destination (phone → profile → driver KYC / home).
///
/// [intendedRole] is the role selected on the login screen (e.g. Apple/Google
/// with "Sürücü" chosen) so first-time drivers are sent to registration even
/// when the backend session still says passenger.
Future<String> resolvePostAuthRoute(
  UserModel? user, {
  String? intendedRole,
}) async {
  if (user == null) return '/login';
  if (user.isAdmin) return '/admin';
  if (needsPhoneNumber(user)) return '/phone-setup';
  if (!isProfileComplete(user)) return '/profile-setup';
  final pending = intendedRole ?? peekPendingIntendedRole();
  final wantsDriver = pending == 'driver' || user.role == 'driver';
  if (wantsDriver) {
    takePendingIntendedRole();
    final route = await resolveDriverEntryRoute();
    if (route == '/driver-home') {
      await passengerGetIt<AppModeCubit>().switchToDriver(isApproved: true);
    } else {
      await passengerGetIt<AppModeCubit>().switchToPassenger();
    }
    return route;
  }
  takePendingIntendedRole();
  await passengerGetIt<AppModeCubit>().switchToPassenger();
  return '/home';
}

String rideStatusLabel(AppLocalizations l10n, RideStatus status) {
  return switch (status) {
    RideStatus.pending => l10n.rideStatusPending,
    RideStatus.driverAssigned => l10n.rideStatusDriverAssigned,
    RideStatus.driverArriving => l10n.rideStatusDriverArriving,
    RideStatus.driverArrived => l10n.rideStatusDriverArrived,
    RideStatus.passengerOnBoard => l10n.rideStatusPassengerOnBoard,
    RideStatus.inProgress => l10n.rideStatusInProgress,
    RideStatus.completed => l10n.rideStatusCompleted,
    RideStatus.cancelledByPassenger => l10n.rideStatusCancelledPassenger,
    RideStatus.cancelledByDriver => l10n.rideStatusCancelledDriver,
    RideStatus.expired => l10n.rideStatusExpired,
  };
}
