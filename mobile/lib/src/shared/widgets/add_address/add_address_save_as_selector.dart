import 'package:flutter/material.dart';

import '../../contracts/customer_address_save_as.dart';
import '../../theme/customer_add_address_tokens.dart';

class AddAddressSaveAsSelector extends StatelessWidget {
  const AddAddressSaveAsSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CustomerAddressSaveAs selected;
  final ValueChanged<CustomerAddressSaveAs> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Save address as',
          style: TextStyle(
            color: CustomerAddAddressTokens.labelGray,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _SaveAsChip(
                icon: Icons.home_rounded,
                selected: selected == CustomerAddressSaveAs.home,
                onTap: () => onChanged(CustomerAddressSaveAs.home),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SaveAsChip(
                icon: Icons.work_outline_rounded,
                selected: selected == CustomerAddressSaveAs.work,
                onTap: () => onChanged(CustomerAddressSaveAs.work),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SaveAsChip(
                icon: Icons.push_pin_outlined,
                selected: selected == CustomerAddressSaveAs.other,
                onTap: () => onChanged(CustomerAddressSaveAs.other),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SaveAsChip extends StatelessWidget {
  const _SaveAsChip({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? Colors.white : CustomerAddAddressTokens.inactiveNavGray;
    final Color bg = selected ? CustomerAddAddressTokens.primaryMaroon : CustomerAddAddressTokens.chipIdleSurface;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(CustomerAddAddressTokens.chipRadius),
      elevation: selected ? 3 : 0,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(CustomerAddAddressTokens.chipRadius),
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 1,
          child: Icon(icon, color: fg, size: 30),
        ),
      ),
    );
  }
}
