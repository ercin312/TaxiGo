enum PaymentMethod {
  cash('cash'),
  wallet('wallet'),
  card('card');

  const PaymentMethod(this.value);

  final String value;

  static PaymentMethod fromString(String? raw) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == raw,
      orElse: () => PaymentMethod.cash,
    );
  }

  String get displayKey => switch (this) {
        PaymentMethod.cash => 'cash',
        PaymentMethod.wallet => 'wallet',
        PaymentMethod.card => 'card',
      };
}
