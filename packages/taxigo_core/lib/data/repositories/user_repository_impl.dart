import 'package:dartz/dartz.dart';

import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../mappers/model_mappers.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/api_exception.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._apiClient, this._authRepository);

  final ApiClient _apiClient;
  final AuthRepository _authRepository;

  Future<bool> get _isLocal async {
    final token = await _authRepository.getStoredToken();
    return _authRepository.isLocalToken(token);
  }

  @override
  Future<Either<String, UserModel>> getProfile() async {
    if (await _isLocal) {
      final user = await _authRepository.getStoredLocalUser();
      if (user == null) return const Left('Oturum bulunamadı');
      return Right(user);
    }
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.user);
      final data = response.data;
      if (data == null) return const Left('Empty response');
      return Right(ModelMappers.userFromJson(data));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserModel>> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    if (await _isLocal) {
      final current = await _authRepository.getStoredLocalUser();
      if (current == null) return const Left('Oturum bulunamadı');
      final updated = current.copyWith(
        name: name ?? current.name,
        email: email ?? current.email,
        avatar: avatar ?? current.avatar,
      );
      await _authRepository.saveLocalUser(updated);
      return Right(updated);
    }
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        ApiEndpoints.user,
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (avatar != null) 'avatar': avatar,
        },
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      return Right(ModelMappers.userFromJson(data));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserModel>> updateLocale(String locale) async {
    if (await _isLocal) {
      final current = await _authRepository.getStoredLocalUser();
      if (current == null) return const Left('Oturum bulunamadı');
      final updated = current.copyWith(locale: locale);
      await _authRepository.saveLocalUser(updated);
      return Right(updated);
    }
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiEndpoints.userLocale,
        data: {'locale': locale},
      );
      final data = response.data;
      if (data == null) return const Left('Empty response');
      return Right(ModelMappers.userFromJson(data));
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> deleteAccount() async {
    if (await _isLocal) {
      await _authRepository.clearToken();
      return const Right(null);
    }
    try {
      await _apiClient.delete(ApiEndpoints.user);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
