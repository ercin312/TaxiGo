part of 'earnings_bloc.dart';

sealed class EarningsState extends Equatable {
  const EarningsState();

  @override
  List<Object?> get props => [];
}

class EarningsInitial extends EarningsState {
  const EarningsInitial();
}

class EarningsLoading extends EarningsState {
  const EarningsLoading();
}

class EarningsLoaded extends EarningsState {
  const EarningsLoaded({
    required this.period,
    required this.totalEarnings,
    required this.rideCount,
    required this.walletBalance,
    required this.recentRides,
    this.isRefreshing = false,
  });

  final EarningsPeriod period;
  final double totalEarnings;
  final int rideCount;
  final double walletBalance;
  final List<RideModel> recentRides;
  final bool isRefreshing;

  EarningsLoaded copyWith({
    EarningsPeriod? period,
    double? totalEarnings,
    int? rideCount,
    double? walletBalance,
    List<RideModel>? recentRides,
    bool? isRefreshing,
  }) {
    return EarningsLoaded(
      period: period ?? this.period,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      rideCount: rideCount ?? this.rideCount,
      walletBalance: walletBalance ?? this.walletBalance,
      recentRides: recentRides ?? this.recentRides,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        period,
        totalEarnings,
        rideCount,
        walletBalance,
        recentRides,
        isRefreshing,
      ];
}

class EarningsFailure extends EarningsState {
  const EarningsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
