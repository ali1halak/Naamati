// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_remote_data_source.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _DonationRemoteDataSource implements DonationRemoteDataSource {
  _DonationRemoteDataSource(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<FoodCategoryListResponseModel> getFoodCategories() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<FoodCategoryListResponseModel>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/food-categories',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late FoodCategoryListResponseModel _value;
    try {
      _value = FoodCategoryListResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DonationListResponseModel> getDonations({
    String? search,
    String? status,
    int? categoryId,
    bool? needsCooking,
    String? from,
    String? to,
    int? page,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'search': search,
      r'status': status,
      r'category': categoryId,
      r'needs_cooking': needsCooking,
      r'from': from,
      r'to': to,
      r'page': page,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DonationListResponseModel>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/donor/requests',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DonationListResponseModel _value;
    try {
      _value = DonationListResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DonationResponseModel> createDonation({
    required int foodCategoryId,
    required bool needsCooking,
    required int quantity,
    String? description,
    String? customCategory,
    required String validUntil,
    required String pickupUntil,
    required String pickupAddress,
    String? pickupNotes,
    double? latitude,
    double? longitude,
    required String contactPhone,
    List<File>? images,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('food_category_id', foodCategoryId.toString()));
    _data.fields.add(MapEntry('needs_cooking', needsCooking.toString()));
    _data.fields.add(MapEntry('quantity', quantity.toString()));
    if (description != null) {
      _data.fields.add(MapEntry('description', description));
    }
    if (customCategory != null) {
      _data.fields.add(MapEntry('custom_category', customCategory));
    }
    _data.fields.add(MapEntry('valid_until', validUntil));
    _data.fields.add(MapEntry('pickup_until', pickupUntil));
    _data.fields.add(MapEntry('pickup_address', pickupAddress));
    if (pickupNotes != null) {
      _data.fields.add(MapEntry('pickup_notes', pickupNotes));
    }
    if (latitude != null) {
      _data.fields.add(MapEntry('latitude', latitude.toString()));
    }
    if (longitude != null) {
      _data.fields.add(MapEntry('longitude', longitude.toString()));
    }
    _data.fields.add(MapEntry('contact_phone', contactPhone));
    if (images != null) {
      _data.files.addAll(
        images.map(
          (i) => MapEntry(
            'images[]',
            MultipartFile.fromFileSync(
              i.path,
              filename: i.path.split(Platform.pathSeparator).last,
            ),
          ),
        ),
      );
    }
    final _options = _setStreamType<DonationResponseModel>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '/donor/requests',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DonationResponseModel _value;
    try {
      _value = DonationResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DonationResponseModel> updateDonation(
    int id, {
    required String method,
    required int foodCategoryId,
    required bool needsCooking,
    required int quantity,
    String? description,
    String? customCategory,
    required String validUntil,
    required String pickupUntil,
    required String pickupAddress,
    String? pickupNotes,
    double? latitude,
    double? longitude,
    required String contactPhone,
    List<String>? removedImageIds,
    List<File>? images,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = FormData();
    _data.fields.add(MapEntry('_method', method));
    _data.fields.add(MapEntry('food_category_id', foodCategoryId.toString()));
    _data.fields.add(MapEntry('needs_cooking', needsCooking.toString()));
    _data.fields.add(MapEntry('quantity', quantity.toString()));
    if (description != null) {
      _data.fields.add(MapEntry('description', description));
    }
    if (customCategory != null) {
      _data.fields.add(MapEntry('custom_category', customCategory));
    }
    _data.fields.add(MapEntry('valid_until', validUntil));
    _data.fields.add(MapEntry('pickup_until', pickupUntil));
    _data.fields.add(MapEntry('pickup_address', pickupAddress));
    if (pickupNotes != null) {
      _data.fields.add(MapEntry('pickup_notes', pickupNotes));
    }
    if (latitude != null) {
      _data.fields.add(MapEntry('latitude', latitude.toString()));
    }
    if (longitude != null) {
      _data.fields.add(MapEntry('longitude', longitude.toString()));
    }
    _data.fields.add(MapEntry('contact_phone', contactPhone));
    removedImageIds?.forEach((i) {
      _data.fields.add(MapEntry('removed_image_ids[]', i));
    });
    if (images != null) {
      _data.files.addAll(
        images.map(
          (i) => MapEntry(
            'images[]',
            MultipartFile.fromFileSync(
              i.path,
              filename: i.path.split(Platform.pathSeparator).last,
            ),
          ),
        ),
      );
    }
    final _options = _setStreamType<DonationResponseModel>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '/donor/requests/${id}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DonationResponseModel _value;
    try {
      _value = DonationResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DonationResponseModel> getDonation(int id) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DonationResponseModel>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/donor/requests/${id}',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DonationResponseModel _value;
    try {
      _value = DonationResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DonationAuditResponseModel> getDonationAudit(int id) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DonationAuditResponseModel>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/donor/requests/${id}/audit',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DonationAuditResponseModel _value;
    try {
      _value = DonationAuditResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DonationResponseModel> cancelDonation(int id, {String? reason}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {'reason': reason};
    _data.removeWhere((k, v) => v == null);
    final _options = _setStreamType<DonationResponseModel>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/donor/requests/${id}/cancel',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DonationResponseModel _value;
    try {
      _value = DonationResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<DonationResponseModel> confirmPickup(int id) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<DonationResponseModel>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/donor/requests/${id}/confirm',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late DonationResponseModel _value;
    try {
      _value = DonationResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<RatingResponseModel> rateDonation(
    int id, {
    required int stars,
    String? comment,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {'stars': stars, 'comment': comment};
    _data.removeWhere((k, v) => v == null);
    final _options = _setStreamType<RatingResponseModel>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/donor/requests/${id}/rate',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late RatingResponseModel _value;
    try {
      _value = RatingResponseModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
