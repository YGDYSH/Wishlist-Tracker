import 'package:flutter_test/flutter_test.dart';
import 'package:wishlist_tracker/core/utils/formatters.dart';

void main() {
  group('Formatters.currency', () {
    test('formats 1000000 as Rp1.000.000', () {
      expect(Formatters.currency(1000000), 'Rp1.000.000');
    });

    test('formats 5000 as Rp5.000', () {
      expect(Formatters.currency(5000), 'Rp5.000');
    });

    test('formats 0 as Rp0', () {
      expect(Formatters.currency(0), 'Rp0');
    });

    test('formats decimals rounded down', () {
      expect(Formatters.currency(1234.9), 'Rp1.235');
    });

    test('no decimal places shown', () {
      final result = Formatters.currency(999999.99);
      expect(result, 'Rp1.000.000');
      expect(result.contains('.'), isTrue);
      expect(result.contains(','), isFalse);
    });
  });
}
