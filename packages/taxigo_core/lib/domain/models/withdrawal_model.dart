import 'package:equatable/equatable.dart';

class WithdrawalModel extends Equatable {
  const WithdrawalModel({
    required this.id,
    required this.amount,
    required this.status,
    this.bankName,
    this.accountNumber,
    this.accountHolder,
    this.rejectionReason,
    this.createdAt,
  });

  final int id;
  final double amount;
  final String status;
  final String? bankName;
  final String? accountNumber;
  final String? accountHolder;
  final String? rejectionReason;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        amount,
        status,
        bankName,
        accountNumber,
        accountHolder,
        rejectionReason,
        createdAt,
      ];
}
