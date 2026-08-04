part of 'earnings_bloc.dart';

enum EarningsPeriod { daily, weekly }

sealed class EarningsEvent extends Equatable {
  const EarningsEvent();

  @override
  List<Object?> get props => [];
}

class EarningsLoadRequested extends EarningsEvent {
  const EarningsLoadRequested();
}

class EarningsPeriodChanged extends EarningsEvent {
  const EarningsPeriodChanged(this.period);

  final EarningsPeriod period;

  @override
  List<Object?> get props => [period];
}
