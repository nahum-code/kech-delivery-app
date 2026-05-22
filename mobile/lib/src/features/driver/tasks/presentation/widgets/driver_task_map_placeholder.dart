import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/geo/map_coordinates.dart';
import '../../../../../shared/theme/driver_app_tokens.dart';
import '../../../../../shared/widgets/map/location_map_preview.dart';

/// Map preview on driver task cards — real OSM tiles when coordinates exist.
class DriverTaskMapPlaceholder extends StatelessWidget {
  const DriverTaskMapPlaceholder({
    super.key,
    this.height = 100,
    this.label,
    this.icon = Icons.map_outlined,
    this.latitude,
    this.longitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.markerRole = MapPreviewMarkerRole.pickup,
    this.showRoute = false,
  });

  final double height;
  final String? label;
  final IconData icon;
  final double? latitude;
  final double? longitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final MapPreviewMarkerRole markerRole;
  final bool showRoute;

  @override
  Widget build(BuildContext context) {
    final LatLng? restaurant = latLngFromValues(latitude, longitude);
    final LatLng? dropoff = latLngFromValues(destinationLatitude, destinationLongitude);

    final List<MapPreviewMarker> markers = <MapPreviewMarker>[];
    if (restaurant != null) {
      markers.add(MapPreviewMarker(position: restaurant, role: markerRole, label: label));
    }
    if (dropoff != null) {
      final bool duplicate =
          restaurant != null &&
          restaurant.latitude == dropoff.latitude &&
          restaurant.longitude == dropoff.longitude;
      if (!duplicate) {
        markers.add(MapPreviewMarker(position: dropoff, role: MapPreviewMarkerRole.dropoff));
      }
    }

    if (markers.isNotEmpty) {
      final LatLng openTarget = dropoff ?? restaurant!;
      return LocationMapPreview(
        height: height,
        markers: markers,
        connectRoute: showRoute && markers.length >= 2,
        overlayHint: 'Open in Maps',
        onTapOpenExternal: () => LocationMapPreview.openInExternalMaps(openTarget),
      );
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: DriverAppTokens.mapPlaceholder,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 36, color: DriverAppTokens.primary),
            if (label != null && label!.isNotEmpty) ...<Widget>[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  label!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DriverAppTokens.bodyGray,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4),
            const Text(
              'Map unavailable — set restaurant location in admin',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: DriverAppTokens.mutedGray),
            ),
          ],
        ),
      ),
    );
  }
}
