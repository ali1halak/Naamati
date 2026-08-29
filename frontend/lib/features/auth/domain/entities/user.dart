import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String? name;
  final String? type;
  final String? email;
  final String? phone;
  final String? accountType;
  final String? status;
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
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    email,
    phone,
    accountType,
    status,
    createdAt,
    updatedAt,
  ];
}
