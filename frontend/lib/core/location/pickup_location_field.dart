import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_constants.dart';
import '../theme/app_text_styles.dart';
import 'location_service.dart';
import 'map_picker_page.dart';
import 'pickup_location.dart';

/// Replaces the old free-text "عنوان الاستلام" field: the donor can no
/// longer type an address by hand — only "استخدام موقعي الحالي" (device GPS)
/// or "تحديد على الخريطة" (drop a pin), both of which resolve to a
/// [PickupLocation] with a reverse-geocoded address already filled in.
///
/// Self-contained (owns its own GPS-loading state and map-picker
/// navigation); the parent form only ever sees the final [PickupLocation]
/// via [onChanged] and is responsible for validating that one was chosen
/// before submitting (there is no [TextFormField] to hook into
/// `Form.validate()` here).
class PickupLocationField extends StatefulWidget {
  final PickupLocation? location;
  final ValueChanged<PickupLocation> onChanged;

  /// Shown before a location is picked. Defaults to the donor "pickup"
  /// wording; charity screens (registration, own profile) pass their own
  /// text since it's their organization's address, not a donation pickup.
  final String placeholderText;

  const PickupLocationField({
    super.key,
    required this.location,
    required this.onChanged,
    this.placeholderText = 'لم يتم تحديد موقع الاستلام بعد',
  });

  @override
  State<PickupLocationField> createState() => _PickupLocationFieldState();
}

class _PickupLocationFieldState extends State<PickupLocationField> {
  final _locationService = LocationService();
  bool _isLocating = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final location = await _locationService.getCurrentLocation();
      widget.onChanged(location);
    } on LocationUnavailableException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _pickOnMap() async {
    final result = await Navigator.of(context).push<PickupLocation>(
      MaterialPageRoute(
        builder: (_) => MapPickerPage(initialLocation: widget.location),
      ),
    );
    if (result != null) widget.onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final location = widget.location;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppConstants.paddingMD.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD.r),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20.r,
                color: location != null
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  location?.address ?? widget.placeholderText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: location != null
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    fontWeight: location != null
                        ? FontWeight.w600
                        : FontWeight.w400,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLocating ? null : _useCurrentLocation,
                icon: _isLocating
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded, size: 18),
                label: Text(
                  'موقعي الحالي',
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 12.sp),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLocating ? null : _pickOnMap,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: Text(
                  'تحديد على الخريطة',
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 12.sp),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
