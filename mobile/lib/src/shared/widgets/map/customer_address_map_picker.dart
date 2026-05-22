import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/geocoding/reverse_geocode.dart';

/// Interactive OSM map embedded in the delivery-address sheet.
///
/// Tapping the map drops a pin and reports the new coordinates via
/// [onPicked]. A search box above the map calls OSM Nominatim and lets
/// the customer jump to a named place. The caller is responsible for
/// reverse-geocoding picks into a human-readable address.
class RestaurantOnMap {
  const RestaurantOnMap({
    required this.position,
    required this.name,
  });

  final LatLng position;
  final String name;
}

class CustomerAddressMapPicker extends StatefulWidget {
  const CustomerAddressMapPicker({
    super.key,
    required this.onPicked,
    this.initial,
    this.restaurant,
    this.height = 220,
  });

  final ValueChanged<LatLng> onPicked;
  final LatLng? initial;
  final RestaurantOnMap? restaurant;
  final double height;

  /// Default fallback center (Addis Ababa, Ethiopia).
  static const LatLng _defaultCenter = LatLng(9.0192, 38.7525);

  @override
  State<CustomerAddressMapPicker> createState() => _CustomerAddressMapPickerState();
}

class _CustomerAddressMapPickerState extends State<CustomerAddressMapPicker> {
  static const Color _maroon = Color(0xFF800020);

  late final MapController _controller = MapController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  LatLng? _pin;
  List<PlaceSearchResult> _results = const <PlaceSearchResult>[];
  bool _searching = false;
  bool _resultsOpen = false;

  @override
  void initState() {
    super.initState();
    _pin = widget.initial;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTap(TapPosition _, LatLng point) {
    setState(() {
      _pin = point;
      _resultsOpen = false;
    });
    widget.onPicked(point);
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final String trimmed = value.trim();
    if (trimmed.length < 3) {
      setState(() {
        _results = const <PlaceSearchResult>[];
        _searching = false;
        _resultsOpen = false;
      });
      return;
    }
    setState(() {
      _searching = true;
      _resultsOpen = true;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final List<PlaceSearchResult> data = await searchPlaces(trimmed);
      if (!mounted) return;
      setState(() {
        _results = data;
        _searching = false;
      });
    });
  }

  void _handleSelectResult(PlaceSearchResult r) {
    FocusScope.of(context).unfocus();
    setState(() {
      _pin = r.position;
      _searchController.text = r.displayName;
      _searchController.selection =
          TextSelection.collapsed(offset: r.displayName.length);
      _resultsOpen = false;
    });
    _controller.move(r.position, 16);
    widget.onPicked(r.position);
  }

  String? _formattedDistance() {
    if (_pin == null || widget.restaurant == null) return null;
    final double km = const Distance().as(LengthUnit.Kilometer, widget.restaurant!.position, _pin!);
    if (km < 1) {
      final int meters = (km * 1000).round();
      return '$meters m from ${widget.restaurant!.name}';
    }
    return '${km.toStringAsFixed(2)} km from ${widget.restaurant!.name}';
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _pin ?? widget.initial ?? widget.restaurant?.position ?? CustomerAddressMapPicker._defaultCenter;
    final String? distanceLabel = _formattedDistance();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SearchField(
          controller: _searchController,
          onChanged: _onQueryChanged,
          onClear: () {
            _searchController.clear();
            _onQueryChanged('');
          },
        ),
        if (_resultsOpen && (_searching || _results.isNotEmpty)) ...<Widget>[
          const SizedBox(height: 6),
          _SearchResultsList(
            searching: _searching,
            results: _results,
            onSelect: _handleSelectResult,
          ),
        ],
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: <Widget>[
                FlutterMap(
                  mapController: _controller,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 14,
                    onTap: _handleTap,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.kech_delivery_mobile',
                    ),
                    MarkerLayer(
                      markers: <Marker>[
                        if (widget.restaurant != null)
                          Marker(
                            point: widget.restaurant!.position,
                            width: 40,
                            height: 40,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: _maroon,
                              size: 32,
                            ),
                          ),
                        if (_pin != null)
                          Marker(
                            point: _pin!,
                            width: 40,
                            height: 40,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_on,
                              color: Color(0xFF1F6FEB),
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                    if (widget.restaurant != null && _pin != null)
                      PolylineLayer(
                        polylines: <Polyline>[
                          Polyline(
                            points: <LatLng>[widget.restaurant!.position, _pin!],
                            color: const Color(0xFF800020).withValues(alpha: 0.6),
                            strokeWidth: 3,
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        'Tap to drop pin',
                        style: TextStyle(
                          color: _maroon,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.restaurant != null) ...<Widget>[
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Icon(Icons.storefront_rounded, size: 14, color: _maroon),
              const SizedBox(width: 4),
              const Text(
                'Restaurant',
                style: TextStyle(fontSize: 11, color: _maroon, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.location_on, size: 14, color: Color(0xFF1F6FEB)),
              const SizedBox(width: 4),
              const Text(
                'Dropoff',
                style: TextStyle(fontSize: 11, color: Color(0xFF1F6FEB), fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (distanceLabel != null)
                Text(
                  distanceLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _maroon),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, size: 18),
        hintText: 'Search a place (e.g. Bole, Atlas Hotel)',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        filled: true,
        fillColor: const Color(0xFFF2F2F2),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.searching,
    required this.results,
    required this.onSelect,
  });

  final bool searching;
  final List<PlaceSearchResult> results;
  final ValueChanged<PlaceSearchResult> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: searching
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Searching…', style: TextStyle(fontSize: 13, color: Color(0xFF5C5C5C))),
                ],
              ),
            )
          : results.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    'No results',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5C5C5C)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: results.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Color(0xFFEDEDED)),
                  itemBuilder: (BuildContext _, int index) {
                    final PlaceSearchResult r = results[index];
                    return InkWell(
                      onTap: () => onSelect(r),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.location_pin, size: 18, color: Color(0xFF800020)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                r.displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
