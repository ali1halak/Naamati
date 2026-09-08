import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

import 'pickup_location.dart';

/// Thrown for every "can't get a location" case the picker UI needs to
/// explain to the user — service disabled, permission refused, or denied
/// forever (needs a trip to system settings).
class LocationUnavailableException implements Exception {
  final String message;
  const LocationUnavailableException(this.message);

  @override
  String toString() => message;
}

/// Wraps device GPS (`geolocator`) and reverse geocoding (`geocoding`) — the
/// two device capabilities behind "استخدام موقعي الحالي" and the map picker's
/// auto-filled address. Neither call touches the network/API layer, so this
/// stays outside the repository/`Either<Failure,T>` pattern, matching how
/// other device-capability plugins (image_picker, showTimePicker) are used
/// directly from the page.
@lazySingleton
class LocationService {
  /// Current GPS position, after making sure location services are on and
  /// permission has been granted (requesting it if not yet decided).
  Future<PickupLocation> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationUnavailableException(
        'خدمة الموقع غير مفعّلة على الجهاز — يرجى تفعيلها من الإعدادات.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationUnavailableException('تم رفض إذن الوصول للموقع.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationUnavailableException(
        'إذن الموقع مرفوض بشكل دائم — يرجى تفعيله من إعدادات التطبيق.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return resolveAddress(position.latitude, position.longitude);
  }

  /// Reverse-geocodes a pin dropped on the map into a [PickupLocation]. Never
  /// throws for a "no result" placemark — falls back to a generic label so a
  /// remote/rural pin never blocks submission.
  Future<PickupLocation> resolveAddress(
    double latitude,
    double longitude,
  ) async {
    String address = 'الموقع المحدد على الخريطة';
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = [
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((p) => p != null && p.trim().isNotEmpty).toSet().toList();
        if (parts.isNotEmpty) address = parts.join('، ');
      }
    } catch (_) {
      // Offline or no geocoder result — keep the generic fallback label.
    }

    return PickupLocation(
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }
}
