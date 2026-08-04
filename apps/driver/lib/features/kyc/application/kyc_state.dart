part of 'kyc_bloc.dart';

sealed class KycState extends Equatable {
  const KycState();

  @override
  List<Object?> get props => [];
}

class KycInitial extends KycState {
  const KycInitial();
}

class KycLoading extends KycState {
  const KycLoading();
}

class KycNeedsRegistration extends KycState {
  const KycNeedsRegistration();
}

class KycRegistrationInProgress extends KycState {
  const KycRegistrationInProgress({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
    required this.documents,
  });

  final String make;
  final String model;
  final int year;
  final String color;
  final String plateNumber;
  final Map<DocumentType, File> documents;

  KycRegistrationInProgress copyWith({
    Map<DocumentType, File>? documents,
  }) {
    return KycRegistrationInProgress(
      make: make,
      model: model,
      year: year,
      color: color,
      plateNumber: plateNumber,
      documents: documents ?? this.documents,
    );
  }

  @override
  List<Object?> get props => [make, model, year, color, plateNumber, documents];
}

class KycPendingApproval extends KycState {
  const KycPendingApproval(this.driver);

  final DriverModel driver;

  @override
  List<Object?> get props => [driver];
}

class KycApproved extends KycState {
  const KycApproved(this.driver);

  final DriverModel driver;

  @override
  List<Object?> get props => [driver];
}

class KycRejected extends KycState {
  const KycRejected(this.driver);

  final DriverModel driver;

  @override
  List<Object?> get props => [driver];
}

class KycFailure extends KycState {
  const KycFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
