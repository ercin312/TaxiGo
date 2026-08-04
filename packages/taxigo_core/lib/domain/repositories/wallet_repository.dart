import 'package:dartz/dartz.dart';

import '../models/promo_model.dart';
import '../models/wallet_model.dart';
import '../models/withdrawal_model.dart';

abstract class WalletRepository {
  Future<Either<String, WalletModel>> getWallet();

  Future<Either<String, List<WalletTransactionModel>>> getTransactions({
    int page = 1,
  });

  Future<Either<String, WalletModel>> topUp(double amount);

  Future<Either<String, PromoModel>> validatePromoCode(String code);

  Future<Either<String, List<WithdrawalModel>>> getWithdrawals({int page = 1});

  Future<Either<String, WithdrawalModel>> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  });
}
