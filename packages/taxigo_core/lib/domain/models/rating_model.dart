import 'package:equatable/equatable.dart';

class RatingModel extends Equatable {
  const RatingModel({
    required this.id,
    required this.rideId,
    required this.raterId,
    required this.ratedId,
    required this.score,
    this.comment,
    this.createdAt,
  });

  final int id;
  final int rideId;
  final int raterId;
  final int ratedId;
  final int score;
  final String? comment;
  final DateTime? createdAt;

  @override
  List<Object?> get props =>
      [id, rideId, raterId, ratedId, score, comment, createdAt];
}
