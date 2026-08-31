// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DonationResponseModel _$DonationResponseModelFromJson(
  Map<String, dynamic> json,
) => DonationResponseModel(
  success: json['success'] as bool,
  data: DonationRequestModel.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$DonationResponseModelToJson(
  DonationResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};

DonationListResponseModel _$DonationListResponseModelFromJson(
  Map<String, dynamic> json,
) => DonationListResponseModel(
  success: json['success'] as bool,
  data: DonationListDataModel.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$DonationListResponseModelToJson(
  DonationListResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};

DonationListDataModel _$DonationListDataModelFromJson(
  Map<String, dynamic> json,
) => DonationListDataModel(
  data: (json['data'] as List<dynamic>)
      .map((e) => DonationRequestModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: json['meta'] == null
      ? null
      : DonationPaginationMetaModel.fromJson(
          json['meta'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$DonationListDataModelToJson(
  DonationListDataModel instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

DonationPaginationMetaModel _$DonationPaginationMetaModelFromJson(
  Map<String, dynamic> json,
) => DonationPaginationMetaModel(
  currentPage: (json['current_page'] as num?)?.toInt(),
  lastPage: (json['last_page'] as num?)?.toInt(),
  perPage: (json['per_page'] as num?)?.toInt(),
  total: (json['total'] as num?)?.toInt(),
);

Map<String, dynamic> _$DonationPaginationMetaModelToJson(
  DonationPaginationMetaModel instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'total': instance.total,
};

RatingResponseModel _$RatingResponseModelFromJson(Map<String, dynamic> json) =>
    RatingResponseModel(
      success: json['success'] as bool,
      data: json['data'] == null
          ? null
          : RatingModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$RatingResponseModelToJson(
  RatingResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};

FoodCategoryListResponseModel _$FoodCategoryListResponseModelFromJson(
  Map<String, dynamic> json,
) => FoodCategoryListResponseModel(
  success: json['success'] as bool,
  data: (json['data'] as List<dynamic>)
      .map((e) => FoodCategoryModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$FoodCategoryListResponseModelToJson(
  FoodCategoryListResponseModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data,
  'message': instance.message,
};
