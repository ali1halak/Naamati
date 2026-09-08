import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [latitude]/[longitude] in the device's Google Maps app (or the web
/// fallback if it isn't installed) — a plain external link, so it needs no
/// API key/billing, unlike rendering a map in-app.
Future<void> openInGoogleMaps(double latitude, double longitude) async {
  final uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// "تحديد على الخريطة" — small pill button a charity taps to open a pickup
/// location in Google Maps. Renders nothing when coordinates are missing
/// (older requests / a donor who somehow has none) rather than a dead button.
class OpenInMapsButton extends StatelessWidget {
  final double? latitude;
  final double? longitude;

  const OpenInMapsButton({super.key, this.latitude, this.longitude});

  @override
  Widget build(BuildContext context) {
    final lat = latitude;
    final lng = longitude;
    if (lat == null || lng == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return TextButton.icon(
      onPressed: () => openInGoogleMaps(lat, lng),
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.map_outlined, size: 16),
      label: const Text(
        'التحديد على الخريطة',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
