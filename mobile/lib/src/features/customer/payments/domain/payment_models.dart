final class PaymentInitResult {
  const PaymentInitResult({
    required this.id,
    required this.orderId,
    required this.txRef,
    required this.checkoutUrl,
    required this.amount,
    required this.currency,
    required this.status,
  });

  final int id;
  final int orderId;
  final String txRef;
  final String checkoutUrl;
  final String amount;
  final String currency;
  final String status;

  factory PaymentInitResult.fromJson(Map<String, dynamic> m) => PaymentInitResult(
        id: m['id'] as int,
        orderId: m['order'] as int,
        txRef: m['chapa_tx_ref'] as String? ?? '',
        checkoutUrl: m['checkout_url'] as String? ?? '',
        amount: '${m['amount']}',
        currency: m['currency'] as String? ?? 'ETB',
        status: m['status'] as String? ?? 'pending',
      );
}

final class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.orderId,
    required this.status,
    required this.txRef,
    this.chapaReference = '',
  });

  final int id;
  final int orderId;
  final String status;
  final String txRef;
  final String chapaReference;

  bool get isSuccess => status == 'success';

  factory PaymentRecord.fromJson(Map<String, dynamic> m) => PaymentRecord(
        id: m['id'] as int,
        orderId: m['order'] as int,
        status: m['status'] as String? ?? '',
        txRef: m['chapa_tx_ref'] as String? ?? '',
        chapaReference: m['chapa_reference'] as String? ?? '',
      );
}
