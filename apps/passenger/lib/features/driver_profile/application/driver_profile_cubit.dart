import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

sealed class DriverProfileState extends Equatable {
  const DriverProfileState();

  @override
  List<Object?> get props => [];
}

class DriverProfileInitial extends DriverProfileState {
  const DriverProfileInitial();
}

class DriverProfileLoading extends DriverProfileState {
  const DriverProfileLoading();
}

class DriverProfileNotRegistered extends DriverProfileState {
  const DriverProfileNotRegistered();
}

class DriverProfileLoaded extends DriverProfileState {
  const DriverProfileLoaded(this.driver);

  final DriverModel driver;

  @override
  List<Object?> get props => [driver];
}

class DriverProfileFailure extends DriverProfileState {
  const DriverProfileFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class DriverProfileCubit extends Cubit<DriverProfileState> {
  DriverProfileCubit({required DriverRepository driverRepository})
      : _driverRepository = driverRepository,
        super(const DriverProfileInitial());

  final DriverRepository _driverRepository;

  Future<void> load() async {
    emit(const DriverProfileLoading());

    final result = await _driverRepository.getProfile();

    result.fold(
      (message) {
        if (message.toLowerCase().contains('not found')) {
          emit(const DriverProfileNotRegistered());
        } else {
          emit(DriverProfileFailure(message));
        }
      },
      (driver) => emit(DriverProfileLoaded(driver)),
    );
  }
}
