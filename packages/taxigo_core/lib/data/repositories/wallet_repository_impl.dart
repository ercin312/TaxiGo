import 'package:dartz/dartz.dart';

import '../../domain/models/promo_model.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/models/withdrawal_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../mappers/model_mappers.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';

class WalletRepositoryImpl implements WalletRepository {
  WalletRepositoryImpl(this._apiClient, this._authRepository);

  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  Future<bool> get _isLocal async {
    final token = await _authRepository.getStoredToken();
    return _authRepository.isLocalToken(token);
  }

  @override
  Future<Either<String, WalletModel>> getWallet() async {
    if (await _isLocal) {
      final user = await _authRepository.getStoredLocalUser();
      return Right(
        WalletModel(
          id: 1,
          userId: user?.id ?? 0,
          balance: 50,
          currency: 'USD',
        ),
      );
    }
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.wallet);
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final wallet = data['wallet'] ?? data;
      if (wallet is! Map<String, dynamic>) {
        return const Left('Invalid wallet response');
      }
      return Right(ModelMappers.walletFromJson(wallet));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<WalletTransactionModel>>> getTransactions({
    int page = 1,
  }) async {
    if (await _isLocal) {
      return Right([
        WalletTransactionModel(
          id: 1,
          type: 'credit',
          amount: 50,
          balanceAfter: 50,
          description: 'Demo bakiye',
          createdAt: DateTime.now(),
        ),
      ]);
    }
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.walletTransactions,
        queryParameters: {'page': page},
      );
      final data = response.data;
      if (data == null) return const Right([]);
      final transactions = data['data'] ?? data['transactions'] ?? data;
      if (transactions is! List) return const Right([]);
      return Right(
        transactions
            .whereType<Map<String, dynamic>>()
            .map(ModelMappers.walletTransactionFromJson)
            .toList(),
      );
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, WalletModel>> topUp(double amount) async {
    if (await _isLocal) {
      final user = await _authRepository.getStoredLocalUser();
      return Right(
        WalletModel(
          id: 1,
          userId: user?.id ?? 0,
          balance: 50 + amount,
          currency: 'USD',
        ),
      );
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.walletTopUp,
        data: {'amount': amount},
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final wallet = data['wallet'] ?? data;
      if (wallet is! Map<String, dynamic>) {
        return const Left('Invalid wallet response');
      }
      return Right(ModelMappers.walletFromJson(wallet));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, PromoModel>> validatePromoCode(String code) async {
    if (await _isLocal) {
      return Right(
        PromoModel(
          code: code,
          discountType: 'fixed',
          discountValue: 2,
          isValid: true,
          discountAmount: 2,
        ),
      );
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.promoValidate,
        data: {'code': code},
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final promo = data['promo'] ?? data;
      if (promo is! Map<String, dynamic>) {
        return const Left('Invalid promo response');
      }
      return Right(ModelMappers.promoFromJson(promo));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<WithdrawalModel>>> getWithdrawals({
    int page = 1,
  }) async {
    if (await _isLocal) return const Right([]);
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.walletWithdrawals,
        queryParameters: {'page': page},
      );
      final data = response.data;
      if (data == null) return const Right([]);
      final items = data['data'] ?? data['withdrawals'] ?? data;
      if (items is! List) return const Right([]);
      return Right(
        items
            .whereType<Map<String, dynamic>>()
            .map(ModelMappers.withdrawalFromJson)
            .toList(),
      );
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, WithdrawalModel>> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
  }) async {
    if (await _isLocal) {
      return Right(
        WithdrawalModel(
          id: 1,
          amount: amount,
          status: 'pending',
          bankName: bankName,
          accountNumber: accountNumber,
          accountHolder: accountHolder,
          createdAt: DateTime.now(),
        ),
      );
    }
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.walletWithdrawals,
        data: {
          'amount': amount,
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_holder': accountHolder,
        },
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      final item = data['withdrawal'] ?? data;
      if (item is! Map<String, dynamic>) {
        return const Left('Invalid withdrawal response');
      }
      return Right(ModelMappers.withdrawalFromJson(item));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
