import 'package:equatable/equatable.dart';

/// A donor's own full profile (backend `DonorProfileResource`).
class DonorProfile extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;

  /// Donor category, e.g. `individual`, `restaurant`, `hotel`, `company`.
  final String type;

  final String? avatarUrl;
  final int completedDonationsCount;
  final String? memberSince;
  final DateTime? createdAt;

  const DonorProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    this.avatarUrl,
    this.completedDonationsCount = 0,
    this.memberSince,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    type,
    avatarUrl,
    completedDonationsCount,
    memberSince,
    createdAt,
  ];
}
