import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_text_styles.dart';
import '../widgets/custom_button.dart';
import 'location_service.dart';
import 'pickup_location.dart';

/// Damascus city center — used only when GPS is unavailable/denied and no
/// prior location exists to center the map on.
const _fallbackCenter = LatLng(33.5138, 36.2765);

/// Full-screen OpenStreetMap picker (no API key/billing — see pubspec).
///
/// UX: the pin stays fixed at the screen center while the map pans
/// underneath it (the common "drag map, not pin" pattern), so there's no
/// marker drag-and-drop to get right. "تأكيد الموقع" reverse-geocodes
/// whatever point ends up under the pin and pops it back.
class MapPickerPage extends StatefulWidget {
  final PickupLocation? initialLocation;

  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final _mapController = MapController();
  final _locationService = LocationService();
  bool _isLocating = false;
  bool _isConfirming = false;

  LatLng get _initialCenter {
    final initial = widget.initialLocation;
    return initial != null
        ? LatLng(initial.latitude, initial.longitude)
        : _fallbackCenter;
  }

  @override
  void initState() {
    super.initState();
    // Best-effort: if no prior location was passed in, try to open the map
    // already centered on the user rather than on Damascus by default.
    if (widget.initialLocation == null) {
      _useCurrentLocation(showErrors: false);
    }
  }

  Future<void> _useCurrentLocation({bool showErrors = true}) async {
    setState(() => _isLocating = true);
    try {
      final location = await _locationService.getCurrentLocation();
      _mapController.move(LatLng(location.latitude, location.longitude), 16);
    } on LocationUnavailableException catch (e) {
      if (showErrors && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      // Ignore silently on the best-effort initial attempt.
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _confirm() async {
    setState(() => _isConfirming = true);
    final center = _mapController.camera.center;
    final location = await _locationService.resolveAddress(
      center.latitude,
      center.longitude,
    );
    if (!mounted) return;
    Navigator.of(context).pop(location);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(
            'تحديد الموقع على الخريطة',
            style: AppTextStyles.titleLarge.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 16.sp,
            ),
          ),
        ),
        body: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _initialCenter,
                initialZoom: widget.initialLocation != null ? 16 : 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.naamati',
                ),
              ],
            ),
            // Fixed center pin — never moves; the map pans underneath it.
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 36.h),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 44.r,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              bottom: 100.h,
              child: FloatingActionButton(
                heroTag: 'use-current-location',
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.primary,
                onPressed: _isLocating ? null : () => _useCurrentLocation(),
                child: _isLocating
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.primary,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 24.h,
              child: CustomButton(
                label: 'تأكيد الموقع',
                onPressed: _confirm,
                isLoading: _isConfirming,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
