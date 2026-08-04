import 'package:dartz/dartz.dart';

import '../models/user_model.dart';

abstract class UserRepository {
  Future<Either<String, UserModel>> getProfile();

  Future<Either<String, UserModel>> updateProfile({
    String? name,
    String? email,
    String? avatar,
  });

  Future<Either<String, UserModel>> updateLocale(String locale);

  Future<Either<String, void>> deleteAccount();
}
