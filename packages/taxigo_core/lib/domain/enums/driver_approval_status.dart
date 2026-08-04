enum DriverApprovalStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  banned('banned');

  const DriverApprovalStatus(this.value);

  final String value;

  static DriverApprovalStatus fromString(String? raw) {
    return DriverApprovalStatus.values.firstWhere(
      (status) => status.value == raw,
      orElse: () => DriverApprovalStatus.pending,
    );
  }

  String get displayKey => switch (this) {
        DriverApprovalStatus.pending => 'approvalPending',
        DriverApprovalStatus.approved => 'approvalApproved',
        DriverApprovalStatus.rejected => 'approvalRejected',
        DriverApprovalStatus.banned => 'approvalBanned',
      };
}
