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
  Future<DonationListResponseModel> getDonations({String? status}) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'status': status};
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
    required String quantityDesc,
    String? description,
    required String validUntil,
    required String pickupUntil,
    required String pickupAddress,
    double? latitude,
    double? longitude,
    required String contactPhone,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = {
      'food_category_id': foodCategoryId,
      'needs_cooking': needsCooking,
      'quantity_desc': quantityDesc,
      'description': description,
      'valid_until': validUntil,
      'pickup_until': pickupUntil,
      'pickup_address': pickupAddress,
      'latitude': latitude,
      'longitude': longitude,
      'contact_phone': contactPhone,
    };
    _data.removeWhere((k, v) => v == null);
    final _options = _setStreamType<DonationResponseModel>(
      Options(method: 'POST', headers: _headers, extra: _extra)
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
  Future<DonationResponseModel> confirmPickup(
    int id, {
    required String qrToken,
  }) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = {'qr_token': qrToken};
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
