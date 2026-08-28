import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String type;
  final String email;
  final String phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.type,
    required this.email,
    required this.phone,
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
    createdAt,
    updatedAt,
  ];
}
