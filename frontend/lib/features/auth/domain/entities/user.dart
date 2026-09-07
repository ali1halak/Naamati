import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String? name;
  final String? type;
  final String? email;
  final String? phone;
  final String? accountType;
  final String? status;

  /// Raw backend fields — a donor's `avatar_url` or a charity's `logo_url`,
  /// never both. Use [photoUrl] to read whichever one applies.
  final String? avatarUrl;
  final String? logoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    this.name,
    this.type,
    this.email,
    this.phone,
    this.accountType,
    this.status,
    this.avatarUrl,
    this.logoUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// The account's photo regardless of role — a donor's avatar or a
  /// charity's logo.
  String? get photoUrl => avatarUrl ?? logoUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    email,
    phone,
    accountType,
    status,
    avatarUrl,
    logoUrl,
    createdAt,
    updatedAt,
  ];
}
