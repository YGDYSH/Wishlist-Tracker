class Formatters {
  Formatters._();

  static String currency(double amount) {
    final value = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }
    return 'Rp${buffer.toString()}';
  }

  static String currencyShort(double amount) {
    if (amount >= 1000000) {
      return 'Rp${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp${(amount / 1000).toStringAsFixed(1)}rb';
    }
    return currency(amount);
  }
}
