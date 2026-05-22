import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/geo/map_coordinates.dart';

/// Marker role for consistent colors/icons across driver and customer maps.
enum MapPreviewMarkerRole { restaurant, pickup, dropoff, driver }

class MapPreviewMarker {
  const MapPreviewMarker({
    required this.position,
    required this.role,
    this.label,
  });

  final LatLng position;
  final MapPreviewMarkerRole role;
  final String? label;
}

/// Read-only OpenStreetMap preview (tiles + markers + optional route line).
class LocationMapPreview extends StatelessWidget {
  const LocationMapPreview({
    super.key,
    required this.markers,
    this.height = 120,
    this.connectRoute = false,
    this.overlayHint,
    this.onTapOpenExternal,
  });

  final List<MapPreviewMarker> markers;
  final double height;
  final bool connectRoute;
  final String? overlayHint;
  final VoidCallback? onTapOpenExternal;

  static const Color _maroon = Color(0xFF800020);

  @override
  Widget build(BuildContext context) {
    final List<MapPreviewMarker> valid =
        markers.where((MapPreviewMarker m) => m.position.latitude.abs() <= 90).toList();
    if (valid.isEmpty) {
      return _EmptyMapFrame(height: height, hint: overlayHint ?? 'Location unavailable');
    }

    final LatLng center = valid.length == 1
        ? valid.first.position
        : centerOf(valid.first.position, valid.last.position);
    final double zoom = valid.length == 1
        ? 15
        : zoomLevelForSpan(valid.first.position, valid.last.position);

    final Widget map = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: <Widget>[
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.kech_delivery_mobile',
            ),
            if (connectRoute && valid.length >= 2)
              PolylineLayer(
                polylines: <Polyline>[
                  Polyline(
                    points: valid.map((MapPreviewMarker m) => m.position).toList(),
                    color: _maroon.withValues(alpha: 0.55),
                    strokeWidth: 3,
                  ),
                ],
              ),
            MarkerLayer(
              markers: valid
                  .map(
                    (MapPreviewMarker m) => Marker(
                      point: m.position,
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        _iconForRole(m.role),
                        size: 34,
                        color: _colorForRole(m.role),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );

    if (onTapOpenExternal == null) {
      return map;
    }

    return Stack(
      children: <Widget>[
        map,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTapOpenExternal,
              child: const SizedBox.expand(),
            ),
          ),
        ),
        if (overlayHint != null)
          Positioned(
            left: 8,
            bottom: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.open_in_new, size: 14, color: _maroon),
                    const SizedBox(width: 4),
                    Text(
                      overlayHint!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _maroon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  static IconData _iconForRole(MapPreviewMarkerRole role) {
    return switch (role) {
      MapPreviewMarkerRole.restaurant => Icons.storefront_rounded,
      MapPreviewMarkerRole.pickup => Icons.store_mall_directory_outlined,
      MapPreviewMarkerRole.dropoff => Icons.location_on,
      MapPreviewMarkerRole.driver => Icons.delivery_dining,
    };
  }

  static Color _colorForRole(MapPreviewMarkerRole role) {
    return switch (role) {
      MapPreviewMarkerRole.restaurant => _maroon,
      MapPreviewMarkerRole.pickup => _maroon,
      MapPreviewMarkerRole.dropoff => const Color(0xFF1F6FEB),
      MapPreviewMarkerRole.driver => const Color(0xFF0D9488),
    };
  }

  static Future<void> openInExternalMaps(LatLng point) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${point.latitude},${point.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _EmptyMapFrame extends StatelessWidget {
  const _EmptyMapFrame({required this.height, required this.hint});

  final double height;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            hint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5C5C5C),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
