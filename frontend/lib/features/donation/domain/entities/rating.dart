import 'package:equatable/equatable.dart';

/// A donor's rating of a charity after a completed donation.
class Rating extends Equatable {
  final int id;

  /// 1–5 stars.
  final int stars;

  /// Optional free-text comment.
  final String? comment;

  final DateTime? createdAt;

  const Rating({required this.id, required this.stars, this.comment, this.createdAt});

  @override
  List<Object?> get props => [id, stars, comment, createdAt];
}
