import '../../domain/entities/my_profile.dart';
import 'charity_account_profile_model.dart';
import 'donor_profile_model.dart';

/// Wire shape of the `{ type, profile }` payload every profile endpoint
/// returns — mirrors how `/me` and login/register already ship `{type, user}`.
///
/// Hand-rolled (rather than `@JsonSerializable`) because which model
/// `profile` decodes into depends on the sibling `type` field — a case
/// `json_serializable` doesn't express directly.
class MyProfileModel extends MyProfile {
  const MyProfileModel({
    required super.accountType,
    super.donor,
    super.charity,
  });

  factory MyProfileModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final profileJson = json['profile'] as Map<String, dynamic>?;

    return MyProfileModel(
      accountType: type,
      donor: type == 'donor' && profileJson != null
          ? DonorProfileModel.fromJson(profileJson)
          : null,
      charity: type == 'charity' && profileJson != null
          ? CharityAccountProfileModel.fromJson(profileJson)
          : null,
    );
  }
}
