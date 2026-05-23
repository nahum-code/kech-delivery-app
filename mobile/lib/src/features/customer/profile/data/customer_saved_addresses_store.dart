import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Locally saved delivery labels (Home / Work / Other) until a profile API exists.
final class CustomerSavedAddress {
  const CustomerSavedAddress({
    required this.label,
    required this.addressLine,
    this.unit = '',
  });

  final String label;
  final String addressLine;
  final String unit;

  String get displayLine {
    if (unit.isEmpty) return addressLine;
    return '$addressLine · $unit';
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'label': label,
        'address_line': addressLine,
        'unit': unit,
      };

  factory CustomerSavedAddress.fromJson(Map<String, dynamic> m) => CustomerSavedAddress(
        label: m['label'] as String? ?? 'Address',
        addressLine: m['address_line'] as String? ?? '',
        unit: m['unit'] as String? ?? '',
      );
}

final class CustomerSavedAddressesStore {
  static const String _storageKey = 'customer_saved_addresses_v1';

  Future<List<CustomerSavedAddress>> loadAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <CustomerSavedAddress>[];
    }
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((dynamic e) => CustomerSavedAddress.fromJson(e as Map<String, dynamic>))
        .where((CustomerSavedAddress a) => a.addressLine.trim().isNotEmpty)
        .toList(growable: false);
  }

  /// Upserts by label (case-insensitive).
  Future<void> upsert(CustomerSavedAddress entry) async {
    final List<CustomerSavedAddress> all = await loadAll();
    final String key = entry.label.trim().toUpperCase();
    final List<CustomerSavedAddress> next = <CustomerSavedAddress>[
      for (final CustomerSavedAddress a in all)
        if (a.label.trim().toUpperCase() != key) a,
      entry,
    ];
    await _save(next);
  }

  Future<void> _save(List<CustomerSavedAddress> entries) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (entries.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }
    final String raw = jsonEncode(entries.map((CustomerSavedAddress e) => e.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }
}
