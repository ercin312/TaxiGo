enum DocumentType {
  identity('identity'),
  license('license'),
  registration('registration'),
  vehiclePhoto('vehicle_photo');

  const DocumentType(this.value);

  final String value;

  static DocumentType fromString(String? raw) {
    return DocumentType.values.firstWhere(
      (type) => type.value == raw,
      orElse: () => DocumentType.identity,
    );
  }

  String get displayKey => switch (this) {
        DocumentType.identity => 'documentIdentity',
        DocumentType.license => 'documentLicense',
        DocumentType.registration => 'documentRegistration',
        DocumentType.vehiclePhoto => 'documentVehiclePhoto',
      };
}
