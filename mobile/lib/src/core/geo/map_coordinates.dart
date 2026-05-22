import 'package:latlong2/latlong.dart';

/// Parses API numeric fields (num, String, null) into a coordinate pair.
LatLng? latLngFromValues(dynamic latitude, dynamic longitude) {
  final double? lat = _readDouble(latitude);
  final double? lng = _readDouble(longitude);
  if (lat == null || lng == null) {
    return null;
  }
  if (lat.abs() > 90 || lng.abs() > 180) {
    return null;
  }
  return LatLng(lat, lng);
}

LatLng? latLngFromMap(Map<String, dynamic>? map) {
  if (map == null) {
    return null;
  }
  return latLngFromValues(map['latitude'], map['longitude']);
}

double? _readDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim());
  }
  return null;
}

/// Picks a map zoom level that fits two points on a small preview card.
double zoomLevelForSpan(LatLng a, LatLng b) {
  final double km = const Distance().as(LengthUnit.Kilometer, a, b);
  if (km < 0.3) return 16;
  if (km < 1) return 15;
  if (km < 3) return 14;
  if (km < 8) return 13;
  if (km < 20) return 12;
  return 11;
}

LatLng centerOf(LatLng a, LatLng b) {
  return LatLng((a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
}
