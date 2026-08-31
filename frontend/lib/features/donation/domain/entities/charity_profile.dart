import 'package:equatable/equatable.dart';

/// Slim charity profile embedded in a donation once a charity accepts it
/// (backend `CharityCardResource`).
class CharityProfile extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String address;

  /// Absolute public-storage URL of the charity logo (may be null).
  final String? logoUrl;

  /// Average rating in stars (null until the first rating arrives).
  final double? ratingAvg;

  /// Total number of ratings received.
  final int ratingsCount;

  /// Total donations this charity has completed.
  final int completedDonationsCount;

  const CharityProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.logoUrl,
    this.ratingAvg,
    required this.ratingsCount,
    required this.completedDonationsCount,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    address,
    logoUrl,
    ratingAvg,
    ratingsCount,
    completedDonationsCount,
  ];
}
