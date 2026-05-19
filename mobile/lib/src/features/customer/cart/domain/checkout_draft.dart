import '../../orders/domain/order_models.dart';

/// Delivery + driver note captured before pay-with-Chapa checkout.
final class CheckoutDraft {
  const CheckoutDraft({
    required this.address,
    this.addressLabel = 'Delivery address',
    this.driverNote = '',
  });

  final DeliveryAddress address;
  final String addressLabel;
  final String driverNote;

  CheckoutDraft copyWith({
    DeliveryAddress? address,
    String? addressLabel,
    String? driverNote,
  }) =>
      CheckoutDraft(
        address: address ?? this.address,
        addressLabel: addressLabel ?? this.addressLabel,
        driverNote: driverNote ?? this.driverNote,
      );
}
