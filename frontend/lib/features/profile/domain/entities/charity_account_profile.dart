import 'package:equatable/equatable.dart';

/// A charity's own full profile (backend `CharityProfileResource`).
///
/// Named distinctly from `donation/domain/entities/charity_profile.dart`
/// (`CharityProfile`), which is the slim card a *donor* sees once a charity
/// accepts its request — this one is the charity's own, richer self-view.
class CharityAccountProfile extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;

  /// `HH:mm` strings.
  final String workStart;
  final String workEnd;

  final bool hasKitchen;

  /// `pending` | `active` | `suspended`.
  final String status;
  final String statusLabel;

  final String? logoUrl;

  /// Null until the first rating lands.
  final double? ratingAvg;
  final int ratingsCount;
  final int completedDonationsCount;

  final String? memberSince;
  final DateTime? createdAt;

  const CharityAccountProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.workStart,
    required this.workEnd,
    required this.hasKitchen,
    required this.status,
    required this.statusLabel,
    this.logoUrl,
    this.ratingAvg,
    this.ratingsCount = 0,
    this.completedDonationsCount = 0,
    this.memberSince,
    this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isSuspended => status == 'suspended';
  bool get isActive => status == 'active';

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    address,
    workStart,
    workEnd,
    hasKitchen,
    status,
    statusLabel,
    logoUrl,
    ratingAvg,
    ratingsCount,
    completedDonationsCount,
    memberSince,
    createdAt,
  ];
}
