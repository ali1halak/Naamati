import 'package:equatable/equatable.dart';

/// A location chosen either via GPS ("استخدام موقعي الحالي") or by dropping a
/// pin on the map picker — [address] is always reverse-geocoded client-side
/// (never typed), so the backend keeps receiving a normal `pickup_address`
/// string alongside a required lat/lng pair.
class PickupLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String address;

  const PickupLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  List<Object?> get props => [latitude, longitude, address];
}
