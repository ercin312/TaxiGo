import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

part 'earnings_event.dart';
part 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  EarningsBloc({
    required DriverRepository driverRepository,
    required WalletRepository walletRepository,
  })  : _driverRepository = driverRepository,
        _walletRepository = walletRepository,
        super(const EarningsInitial()) {
    on<EarningsLoadRequested>(_onLoadRequested);
    on<EarningsPeriodChanged>(_onPeriodChanged);
  }

  final DriverRepository _driverRepository;
  final WalletRepository _walletRepository;

  Future<void> _onLoadRequested(
    EarningsLoadRequested event,
    Emitter<EarningsState> emit,
  ) async {
    emit(const EarningsLoading());
    await _loadStats(EarningsPeriod.daily, emit);
  }

  Future<void> _onPeriodChanged(
    EarningsPeriodChanged event,
    Emitter<EarningsState> emit,
  ) async {
    emit(const EarningsLoading());
    await _loadStats(event.period, emit);
  }

  Future<void> _loadStats(
    EarningsPeriod period,
    Emitter<EarningsState> emit,
  ) async {
    final ridesResult = await _driverRepository.getRideHistory(page: 1);
    final walletResult = await _walletRepository.getWallet();

    ridesResult.fold(
      (message) => emit(EarningsFailure(message)),
      (rides) {
        final now = DateTime.now();
        final cutoff = period == EarningsPeriod.daily
            ? DateTime(now.year, now.month, now.day)
            : now.subtract(const Duration(days: 7));

        final completedRides = rides.where((r) {
          if (r.status != RideStatus.completed || r.completedAt == null) {
            return false;
          }
          return r.completedAt!.isAfter(cutoff);
        }).toList();

        final totalEarnings = completedRides.fold<double>(
          0,
          (sum, r) => sum + (r.finalFare ?? 0),
        );

        walletResult.fold(
          (message) => emit(EarningsFailure(message)),
          (wallet) => emit(EarningsLoaded(
            period: period,
            totalEarnings: totalEarnings,
            rideCount: completedRides.length,
            walletBalance: wallet.balance,
            recentRides: completedRides.take(10).toList(),
          )),
        );
      },
    );
  }
}
