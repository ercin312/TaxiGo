import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxigo_core/taxigo_core.dart';

part 'kyc_event.dart';
part 'kyc_state.dart';

class KycBloc extends Bloc<KycEvent, KycState> {
  KycBloc({required DriverRepository driverRepository})
      : _driverRepository = driverRepository,
        super(const KycInitial()) {
    on<KycCheckStatus>(_onCheckStatus);
    on<KycVehicleInfoSubmitted>(_onVehicleInfoSubmitted);
    on<KycDocumentSelected>(_onDocumentSelected);
    on<KycSubmitRegistration>(_onSubmitRegistration);
  }

  final DriverRepository _driverRepository;

  String? _make;
  String? _model;
  int? _year;
  String? _color;
  String? _plateNumber;
  final Map<DocumentType, File> _documents = {};

  Future<void> _onCheckStatus(
    KycCheckStatus event,
    Emitter<KycState> emit,
  ) async {
    emit(const KycLoading());

    final result = await _driverRepository.getProfile();

    result.fold(
      (message) {
        if (message.toLowerCase().contains('not found')) {
          emit(const KycNeedsRegistration());
        } else {
          emit(KycFailure(message));
        }
      },
      (driver) {
        switch (driver.approvalStatus) {
          case DriverApprovalStatus.approved:
            emit(KycApproved(driver));
          case DriverApprovalStatus.pending:
            emit(KycPendingApproval(driver));
          case DriverApprovalStatus.rejected:
          case DriverApprovalStatus.banned:
            emit(KycRejected(driver));
        }
      },
    );
  }

  void _onVehicleInfoSubmitted(
    KycVehicleInfoSubmitted event,
    Emitter<KycState> emit,
  ) {
    _make = event.make;
    _model = event.model;
    _year = event.year;
    _color = event.color;
    _plateNumber = event.plateNumber;
    emit(KycRegistrationInProgress(
      make: _make!,
      model: _model!,
      year: _year!,
      color: _color!,
      plateNumber: _plateNumber!,
      documents: Map.from(_documents),
    ));
  }

  void _onDocumentSelected(
    KycDocumentSelected event,
    Emitter<KycState> emit,
  ) {
    _documents[event.type] = event.file;
    if (state is KycRegistrationInProgress) {
      final current = state as KycRegistrationInProgress;
      emit(current.copyWith(documents: Map.from(_documents)));
    }
  }

  Future<void> _onSubmitRegistration(
    KycSubmitRegistration event,
    Emitter<KycState> emit,
  ) async {
    if (_make == null ||
        _model == null ||
        _year == null ||
        _color == null ||
        _plateNumber == null) {
      emit(const KycFailure('Please fill in all vehicle details'));
      return;
    }

    emit(const KycLoading());

    final registerResult = await _driverRepository.register(
      vehicleMake: _make!,
      vehicleModel: _model!,
      vehicleYear: _year!,
      vehicleColor: _color!,
      vehiclePlate: _plateNumber!,
    );

    final driver = registerResult.fold(
      (message) {
        emit(KycFailure(message));
        return null;
      },
      (driver) => driver,
    );

    if (driver == null) return;

    for (final entry in _documents.entries) {
      final uploadResult = await _driverRepository.uploadDocument(
        type: entry.key,
        filePath: entry.value.path,
      );
      uploadResult.fold(
        (message) => emit(KycFailure(message)),
        (_) {},
      );
    }

    add(const KycCheckStatus());
  }
}
