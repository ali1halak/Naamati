import 'package:equatable/equatable.dart';

import 'charity_account_profile.dart';
import 'donor_profile.dart';

/// The signed-in account's own profile — exactly one of [donor]/[charity] is
/// set, matching which type the backend resolved the request to.
class MyProfile extends Equatable {
  final String accountType;
  final DonorProfile? donor;
  final CharityAccountProfile? charity;

  const MyProfile({required this.accountType, this.donor, this.charity});

  bool get isDonor => accountType == 'donor';
  bool get isCharity => accountType == 'charity';

  /// Display name regardless of which side is populated.
  String get name => donor?.name ?? charity?.name ?? '';

  String get email => donor?.email ?? charity?.email ?? '';

  String? get avatarUrl => donor?.avatarUrl ?? charity?.logoUrl;

  @override
  List<Object?> get props => [accountType, donor, charity];
}
