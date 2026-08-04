import 'package:dartz/dartz.dart';

extension EitherExtensions<L, R> on Either<L, R> {
  R? get rightOrNull => fold((_) => null, (value) => value);

  L? get leftOrNull => fold((value) => value, (_) => null);

  Either<L, T> mapRight<T>(T Function(R value) transform) {
    return fold(
      (left) => Left(left),
      (right) => Right(transform(right)),
    );
  }

  Either<T, R> mapLeft<T>(T Function(L value) transform) {
    return fold(
      (left) => Left(transform(left)),
      (right) => Right(right),
    );
  }

  Future<Either<L, T>> flatMapAsync<T>(
    Future<Either<L, T>> Function(R value) transform,
  ) async {
    return fold(
      (left) => Left(left),
      (right) => transform(right),
    );
  }

  R getOrElse(R Function() orElse) {
    return fold((_) => orElse(), (value) => value);
  }

  void when({
    required void Function(L left) onLeft,
    required void Function(R right) onRight,
  }) {
    fold(onLeft, onRight);
  }
}
