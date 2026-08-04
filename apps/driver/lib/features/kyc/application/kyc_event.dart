part of 'kyc_bloc.dart';

sealed class KycEvent extends Equatable {
  const KycEvent();

  @override
  List<Object?> get props => [];
}

class KycCheckStatus extends KycEvent {
  const KycCheckStatus();
}

class KycVehicleInfoSubmitted extends KycEvent {
  const KycVehicleInfoSubmitted({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
  });

  final String make;
  final String model;
  final int year;
  final String color;
  final String plateNumber;

  @override
  List<Object?> get props => [make, model, year, color, plateNumber];
}

class KycDocumentSelected extends KycEvent {
  const KycDocumentSelected({required this.type, required this.file});

  final DocumentType type;
  final File file;

  @override
  List<Object?> get props => [type, file];
}

class KycSubmitRegistration extends KycEvent {
  const KycSubmitRegistration();
}

class KycUploadDocument extends KycEvent {
  const KycUploadDocument({required this.type, required this.file});

  final DocumentType type;
  final File file;

  @override
  List<Object?> get props => [type, file];
}
