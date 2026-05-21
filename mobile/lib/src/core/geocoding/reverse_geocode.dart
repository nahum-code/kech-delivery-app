import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Reverse-geocode a coordinate via OpenStreetMap's free Nominatim API.
///
/// Returns the resolved address string, or `null` if the call failed or
/// produced no result. Nominatim's usage policy asks for an identifying
/// User-Agent and limits clients to ~1 request per second.
/// A single forward-geocoding result returned by Nominatim search.
class PlaceSearchResult {
  const PlaceSearchResult({
    required this.placeId,
    required this.displayName,
    required this.position,
  });

  final int placeId;
  final String displayName;
  final LatLng position;
}

/// Forward-geocode a free-text query via OpenStreetMap's Nominatim API.
///
/// Returns at most [limit] matches ordered by Nominatim's relevance ranking.
/// Returns an empty list if the call fails or yields no matches.
Future<List<PlaceSearchResult>> searchPlaces(
  String query, {
  int limit = 5,
}) async {
  final String trimmed = query.trim();
  if (trimmed.length < 3) return const <PlaceSearchResult>[];
  final Uri uri = Uri.parse(
    'https://nominatim.openstreetmap.org/search'
    '?format=jsonv2'
    '&limit=$limit'
    '&q=${Uri.encodeQueryComponent(trimmed)}',
  );
  try {
    final http.Response res = await http.get(
      uri,
      headers: const <String, String>{
        'Accept': 'application/json',
        'User-Agent': 'kech_delivery_mobile/1.0 (kech-delivery)',
      },
    );
    if (res.statusCode != 200) return const <PlaceSearchResult>[];
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    return data.whereType<Map<String, dynamic>>().map((Map<String, dynamic> row) {
      final double? lat = double.tryParse('${row['lat']}');
      final double? lon = double.tryParse('${row['lon']}');
      return PlaceSearchResult(
        placeId: (row['place_id'] as num?)?.toInt() ?? 0,
        displayName: row['display_name'] as String? ?? '',
        position: LatLng(lat ?? 0, lon ?? 0),
      );
    }).where((PlaceSearchResult r) => r.displayName.isNotEmpty).toList(growable: false);
  } catch (_) {
    return const <PlaceSearchResult>[];
  }
}

Future<String?> reverseGeocode(LatLng position) async {
  final Uri uri = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse'
    '?format=jsonv2'
    '&lat=${position.latitude}'
    '&lon=${position.longitude}',
  );
  try {
    final http.Response res = await http.get(
      uri,
      headers: const <String, String>{
        'Accept': 'application/json',
        'User-Agent': 'kech_delivery_mobile/1.0 (kech-delivery)',
      },
    );
    if (res.statusCode != 200) return null;
    final Map<String, dynamic> data = jsonDecode(res.body) as Map<String, dynamic>;
    final String? name = data['display_name'] as String?;
    if (name == null || name.isEmpty) return null;
    return name;
  } catch (_) {
    return null;
  }
}
