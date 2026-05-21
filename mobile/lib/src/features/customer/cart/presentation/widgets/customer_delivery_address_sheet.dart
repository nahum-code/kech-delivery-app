import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/geocoding/reverse_geocode.dart';
import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../../../shared/widgets/map/customer_address_map_picker.dart';
import '../../../orders/domain/order_models.dart';
import '../../domain/checkout_draft.dart';

Future<CheckoutDraft?> showCustomerDeliveryAddressSheet(
  BuildContext context, {
  CheckoutDraft? initial,
  RestaurantOnMap? restaurant,
}) {
  return showModalBottomSheet<CheckoutDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: _DeliveryAddressSheet(initial: initial, restaurant: restaurant),
    ),
  );
}

class _DeliveryAddressSheet extends StatefulWidget {
  const _DeliveryAddressSheet({this.initial, this.restaurant});

  final CheckoutDraft? initial;
  final RestaurantOnMap? restaurant;

  @override
  State<_DeliveryAddressSheet> createState() => _DeliveryAddressSheetState();
}

class _DeliveryAddressSheetState extends State<_DeliveryAddressSheet> {
  late final TextEditingController _label;
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _line;
  late final TextEditingController _landmark;

  LatLng? _pickedPoint;
  bool _geocoding = false;

  @override
  void initState() {
    super.initState();
    final DeliveryAddress? a = widget.initial?.address;
    _label = TextEditingController(text: widget.initial?.addressLabel ?? 'Home');
    _name = TextEditingController(text: a?.receiverName ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _line = TextEditingController(text: a?.addressLine ?? '');
    _landmark = TextEditingController(text: a?.landmark ?? '');
    if (a?.latitude != null && a?.longitude != null) {
      _pickedPoint = LatLng(a!.latitude!, a.longitude!);
    }
  }

  @override
  void dispose() {
    _label.dispose();
    _name.dispose();
    _phone.dispose();
    _line.dispose();
    _landmark.dispose();
    super.dispose();
  }

  Future<void> _onMapPicked(LatLng point) async {
    setState(() {
      _pickedPoint = point;
      _geocoding = true;
    });
    final String? address = await reverseGeocode(point);
    if (!mounted) return;
    setState(() {
      _geocoding = false;
      if (address != null && address.isNotEmpty) {
        _line.text = address;
        _line.selection = TextSelection.collapsed(offset: address.length);
      }
    });
  }

  void _save() {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty || _line.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, phone, and address are required.')),
      );
      return;
    }
    Navigator.of(context).pop(
      CheckoutDraft(
        addressLabel: _label.text.trim().isEmpty ? 'Delivery address' : _label.text.trim(),
        address: DeliveryAddress(
          receiverName: _name.text.trim(),
          phone: _phone.text.trim(),
          addressLine: _line.text.trim(),
          landmark: _landmark.text.trim(),
          latitude: _pickedPoint?.latitude,
          longitude: _pickedPoint?.longitude,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Delivery address', style: CustomerCheckoutTokens.sectionTitle(context)),
            const SizedBox(height: 8),
            Text(
              'Tap on the map to set your dropoff. You can fine-tune the address below.',
              style: TextStyle(color: CustomerCheckoutTokens.mutedGray, fontSize: 12),
            ),
            const SizedBox(height: 12),
            CustomerAddressMapPicker(
              initial: _pickedPoint,
              restaurant: widget.restaurant,
              onPicked: _onMapPicked,
            ),
            if (_geocoding) ...<Widget>[
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomerCheckoutTokens.primaryMaroon,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Looking up address…',
                    style: TextStyle(color: CustomerCheckoutTokens.mutedGray, fontSize: 12),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            _field(_label, 'Label (e.g. Home)'),
            const SizedBox(height: 10),
            _field(_name, 'Receiver name *'),
            const SizedBox(height: 10),
            _field(_phone, 'Phone *', keyboard: TextInputType.phone),
            const SizedBox(height: 10),
            _field(_line, 'Address *', maxLines: 2),
            const SizedBox(height: 10),
            _field(_landmark, 'Landmark (optional)'),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: CustomerCheckoutTokens.primaryMaroon,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Save address',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboard, int maxLines = 1}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(
        color: CustomerCheckoutTokens.ink,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: CustomerCheckoutTokens.primaryMaroon,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: CustomerCheckoutTokens.primaryMaroon,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: CustomerCheckoutTokens.primaryMaroon,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: TextStyle(color: CustomerCheckoutTokens.mutedGray, fontSize: 14),
        filled: true,
        fillColor: CustomerCheckoutTokens.fieldFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CustomerCheckoutTokens.primaryMaroon, width: 1.2),
        ),
      ),
    );
  }
}
