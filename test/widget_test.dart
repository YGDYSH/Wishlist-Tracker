import 'package:flutter_test/flutter_test.dart';
import 'package:wishlist_tracker/data/models/wishlist_item.dart';

void main() {
  test('WishlistItem defaults are set correctly', () {
    final item = WishlistItem(id: '1', name: 'MacBook');

    expect(item.name, 'MacBook');
    expect(item.description, '');
    expect(item.isPurchased, false);
    expect(item.targetPrice, isNull);
    expect(item.imageUrl, isNull);
    expect(item.savedAmount, 0.0);
  });

  test('WishlistItem can be marked as purchased', () {
    final item = WishlistItem(id: '2', name: 'Camera', targetPrice: 1200.50);

    item.isPurchased = true;

    expect(item.isPurchased, true);
    expect(item.targetPrice, 1200.50);
  });

  group('progressPercentage', () {
    test('returns 0 when targetPrice is null', () {
      final item = WishlistItem(id: '1', name: 'Thing');
      expect(item.progressPercentage, 0.0);
    });

    test('returns 0 when targetPrice is 0', () {
      final item = WishlistItem(id: '1', name: 'Thing', targetPrice: 0);
      expect(item.progressPercentage, 0.0);
    });

    test('calculates 50% progress', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 500,
      );
      expect(item.progressPercentage, 50.0);
    });

    test('clamps to 100% when saved exceeds target', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 1500,
      );
      expect(item.progressPercentage, 100.0);
    });

    test('clamps to 0% when saved is negative-like via clamp', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 0,
      );
      expect(item.progressPercentage, 0.0);
    });
  });

  group('remainingAmount', () {
    test('returns 0 when targetPrice is null', () {
      final item = WishlistItem(id: '1', name: 'Thing');
      expect(item.remainingAmount, 0.0);
    });

    test('returns remaining when below target', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 400,
      );
      expect(item.remainingAmount, 600);
    });

    test('returns 0 when saved meets or exceeds target', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 1000,
      );
      expect(item.remainingAmount, 0.0);
    });
  });

  group('isTargetReached', () {
    test('returns false when saved less than target', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 999,
      );
      expect(item.isTargetReached, isFalse);
    });

    test('returns true when saved equals target', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 1000,
      );
      expect(item.isTargetReached, isTrue);
    });

    test('returns true when saved exceeds target', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 1200,
      );
      expect(item.isTargetReached, isTrue);
    });

    test('returns false when targetPrice is null', () {
      final item = WishlistItem(id: '1', name: 'Thing', savedAmount: 1000);
      expect(item.isTargetReached, isFalse);
    });
  });

  group('status', () {
    test('returns mulaiMenabung for < 50% progress', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 400,
      );
      expect(item.status, WishlistStatus.mulaiMenabung);
      expect(item.statusLabel, 'Mulai Menabung');
    });

    test('returns sedangBerjalan for 50% <= progress < 100%', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 500,
      );
      expect(item.status, WishlistStatus.sedangBerjalan);
      expect(item.statusLabel, 'Sedang Berjalan');
    });

    test('returns targetTercapai at exactly 100%', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 1000,
      );
      expect(item.status, WishlistStatus.targetTercapai);
      expect(item.statusLabel, 'Target Tercapai');
    });
  });

  group('progressFraction', () {
    test('is 0 when targetPrice is null', () {
      final item = WishlistItem(id: '1', name: 'Thing');
      expect(item.progressFraction, 0.0);
    });

    test('is 0.5 for half of target', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 500,
      );
      expect(item.progressFraction, 0.5);
    });

    test('clamps to 1.0 when saved exceeds target', () {
      final item = WishlistItem(
        id: '1',
        name: 'Thing',
        targetPrice: 1000,
        savedAmount: 1500,
      );
      expect(item.progressFraction, 1.0);
    });
  });
}
