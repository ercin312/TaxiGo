import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../app_mode/application/app_mode_cubit.dart';
import '../../application/kyc_bloc.dart';

class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<KycBloc, KycState>(
      listener: (context, state) {
        if (state is KycApproved) {
          context.read<AppModeCubit>().switchToDriver(isApproved: true);
          context.go('/driver-home');
        }
      },
      builder: (context, state) {
        final isRejected = state is KycRejected;
        final rejectionReason =
            isRejected ? state.driver.rejectionReason : null;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isRejected ? Icons.cancel_outlined : Icons.hourglass_top,
                    size: 80,
                    color: isRejected ? Colors.red : AppColors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isRejected
                        ? l10n.approvalRejected
                        : l10n.approvalPending,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rejectionReason ??
                        'Belgeleriniz incelendikten sonra taksi modu açılacak. '
                            'Onay için admin paneli gerekir.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  PrimaryButton(
                    label: l10n.tryAgain,
                    onPressed: () {
                      context.read<KycBloc>().add(const KycCheckStatus());
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.read<AppModeCubit>().switchToPassenger();
                      context.go('/home');
                    },
                    child: const Text('Yolcu moduna dön'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
