import 'package:flutter/material.dart';

import '../../../../../shared/theme/customer_checkout_tokens.dart';
import '../../../orders/domain/order_models.dart';
import '../../domain/checkout_draft.dart';

Future<CheckoutDraft?> showCustomerDeliveryAddressSheet(
  BuildContext context, {
  CheckoutDraft? initial,
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
      child: _DeliveryAddressSheet(initial: initial),
    ),
  );
}

class _DeliveryAddressSheet extends StatefulWidget {
  const _DeliveryAddressSheet({this.initial});

  final CheckoutDraft? initial;

  @override
  State<_DeliveryAddressSheet> createState() => _DeliveryAddressSheetState();
}

class _DeliveryAddressSheetState extends State<_DeliveryAddressSheet> {
  late final TextEditingController _label;
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _line;
  late final TextEditingController _landmark;

  @override
  void initState() {
    super.initState();
    final DeliveryAddress? a = widget.initial?.address;
    _label = TextEditingController(text: widget.initial?.addressLabel ?? 'Home');
    _name = TextEditingController(text: a?.receiverName ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _line = TextEditingController(text: a?.addressLine ?? '');
    _landmark = TextEditingController(text: a?.landmark ?? '');
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Save address'),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboard, int maxLines = 1}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: CustomerCheckoutTokens.fieldFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
