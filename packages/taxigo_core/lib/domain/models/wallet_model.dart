import 'package:equatable/equatable.dart';

class WalletTransactionModel extends Equatable {
  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.description,
    this.rideId,
    this.createdAt,
  });

  final int id;
  final String type;
  final double amount;
  final double balanceAfter;
  final String? description;
  final int? rideId;
  final DateTime? createdAt;

  @override
  List<Object?> get props =>
      [id, type, amount, balanceAfter, description, rideId, createdAt];
}

class WalletModel extends Equatable {
  const WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    this.currency = 'USD',
    this.transactions = const [],
  });

  final int id;
  final int userId;
  final double balance;
  final String currency;
  final List<WalletTransactionModel> transactions;

  WalletModel copyWith({
    int? id,
    int? userId,
    double? balance,
    String? currency,
    List<WalletTransactionModel>? transactions,
  }) {
    return WalletModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [id, userId, balance, currency, transactions];
}
