import 'package:equatable/equatable.dart';

class ComplaintModel extends Equatable {
  const ComplaintModel({
    required this.id,
    required this.userId,
    this.rideId,
    required this.subject,
    required this.description,
    this.status = 'open',
    this.adminResponse,
    this.resolvedAt,
    this.createdAt,
  });

  final int id;
  final int userId;
  final int? rideId;
  final String subject;
  final String description;
  final String status;
  final String? adminResponse;
  final DateTime? resolvedAt;
  final DateTime? createdAt;

  bool get isResolved => status == 'resolved';

  @override
  List<Object?> get props => [
        id,
        userId,
        rideId,
        subject,
        description,
        status,
        adminResponse,
        resolvedAt,
        createdAt,
      ];
}
