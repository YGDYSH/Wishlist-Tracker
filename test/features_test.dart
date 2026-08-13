import 'package:flutter_test/flutter_test.dart';
import 'package:wishlist_tracker/data/models/wishlist_item.dart';
import 'package:wishlist_tracker/presentation/helpers.dart';

WishlistItem makeItem({
  required String id,
  required String name,
  double target = 1000000,
  double saved = 0,
  WishlistCategory category = WishlistCategory.lainnya,
  DateTime? createdAt,
  DateTime? targetDate,
  String description = '',
}) {
  return WishlistItem(
    id: id,
    name: name,
    targetPrice: target,
    savedAmount: saved,
    category: category,
    createdAt: createdAt,
    targetDate: targetDate,
    description: description,
  );
}

void main() {
  group('category', () {
    test('defaults to lainnya when not provided', () {
      final item = WishlistItem(id: '1', name: 'Barang');
      expect(item.category, WishlistCategory.lainnya);
    });

    test('stores and returns the assigned category', () {
      final item = makeItem(
        id: '1',
        name: 'Laptop',
        category: WishlistCategory.elektronik,
      );
      expect(item.category, WishlistCategory.elektronik);
      expect(item.category.label, 'Elektronik');
    });

    test('all categories have a non-empty label', () {
      for (final c in WishlistCategory.values) {
        expect(c.label.isNotEmpty, isTrue);
      }
    });

    test('category can be reassigned', () {
      final item = makeItem(id: '1', name: 'X');
      item.category = WishlistCategory.gaming;
      expect(item.category, WishlistCategory.gaming);
    });
  });

  group('targetDate', () {
    test('is null by default and no deadline label', () {
      final item = makeItem(id: '1', name: 'X');
      expect(item.targetDate, isNull);
      expect(item.deadlineLabel(), isNull);
      expect(item.isOverdue(), isFalse);
    });

    test('is overdue when date passed and target not reached', () {
      final item = makeItem(
        id: '1',
        name: 'X',
        target: 1000,
        saved: 200,
        targetDate: DateTime(2020, 1, 1),
      );
      expect(item.isOverdue(now: DateTime(2026, 1, 1)), isTrue);
      expect(item.deadlineLabel(now: DateTime(2026, 1, 1)), 'Target terlewat');
    });

    test('is not overdue when target reached even if date passed', () {
      final item = makeItem(
        id: '1',
        name: 'X',
        target: 1000,
        saved: 1000,
        targetDate: DateTime(2020, 1, 1),
      );
      expect(item.isOverdue(now: DateTime(2026, 1, 1)), isFalse);
      expect(item.deadlineLabel(now: DateTime(2026, 1, 1)), 'Target tercapai');
    });

    test('is not overdue when date is in the future', () {
      final item = makeItem(
        id: '1',
        name: 'X',
        target: 1000,
        saved: 100,
        targetDate: DateTime(2030, 1, 1),
      );
      expect(item.isOverdue(now: DateTime(2026, 1, 1)), isFalse);
    });
  });

  group('search', () {
    final items = [
      makeItem(
        id: '1',
        name: 'Laptop Gaming',
        category: WishlistCategory.gaming,
      ),
      makeItem(
        id: '2',
        name: 'Sepatu Lari',
        category: WishlistCategory.fashion,
      ),
      makeItem(
        id: '3',
        name: 'Monitor',
        category: WishlistCategory.elektronik,
        description: 'buat kerja',
      ),
    ];

    List<WishlistItem> search(String q) => applyFilters(
      items: items,
      query: q,
      filter: FilterOption.all,
      sort: SortOption.terbaru,
    );

    test('empty query returns all items', () {
      expect(search('').length, 3);
    });

    test('matches by name, case insensitive', () {
      final result = search('laptop');
      expect(result.length, 1);
      expect(result.first.name, 'Laptop Gaming');
    });

    test('matches by partial name', () {
      expect(search('sepa').length, 1);
    });

    test('matches by category label', () {
      final result = search('elektronik');
      expect(result.length, 1);
      expect(result.first.name, 'Monitor');
    });

    test('matches by description', () {
      expect(search('kerja').length, 1);
    });

    test('returns empty when nothing matches', () {
      expect(search('zzzz'), isEmpty);
    });
  });

  group('filter', () {
    final items = [
      makeItem(id: '1', name: 'Belum', target: 1000, saved: 100),
      makeItem(id: '2', name: 'Berjalan', target: 1000, saved: 600),
      makeItem(id: '3', name: 'Selesai', target: 1000, saved: 1000),
    ];

    List<WishlistItem> filter(FilterOption f) => applyFilters(
      items: items,
      query: '',
      filter: f,
      sort: SortOption.terbaru,
    );

    test('all returns everything', () {
      expect(filter(FilterOption.all).length, 3);
    });

    test('belumTercapai returns only < 50% progress', () {
      final result = filter(FilterOption.belumTercapai);
      expect(result.length, 1);
      expect(result.first.name, 'Belum');
    });

    test('sedangBerjalan returns only 50-99% progress', () {
      final result = filter(FilterOption.sedangBerjalan);
      expect(result.length, 1);
      expect(result.first.name, 'Berjalan');
    });

    test('tercapai returns only completed', () {
      final result = filter(FilterOption.tercapai);
      expect(result.length, 1);
      expect(result.first.name, 'Selesai');
    });
  });

  group('sorting', () {
    final items = [
      makeItem(
        id: '1',
        name: 'Beta',
        target: 3000,
        saved: 300,
        createdAt: DateTime(2026, 1, 1),
      ),
      makeItem(
        id: '2',
        name: 'Alpha',
        target: 1000,
        saved: 900,
        createdAt: DateTime(2026, 3, 1),
      ),
      makeItem(
        id: '3',
        name: 'Charlie',
        target: 2000,
        saved: 1000,
        createdAt: DateTime(2026, 2, 1),
      ),
    ];

    List<String> sortedNames(SortOption s) => applyFilters(
      items: items,
      query: '',
      filter: FilterOption.all,
      sort: s,
    ).map((e) => e.name).toList();

    test('terbaru sorts by createdAt descending', () {
      expect(sortedNames(SortOption.terbaru), ['Alpha', 'Charlie', 'Beta']);
    });

    test('namaAz sorts alphabetically', () {
      expect(sortedNames(SortOption.namaAz), ['Alpha', 'Beta', 'Charlie']);
    });

    test('namaZa sorts reverse alphabetically', () {
      expect(sortedNames(SortOption.namaZa), ['Charlie', 'Beta', 'Alpha']);
    });

    test('targetTerendah sorts by target ascending', () {
      expect(sortedNames(SortOption.targetTerendah), [
        'Alpha',
        'Charlie',
        'Beta',
      ]);
    });

    test('targetTertinggi sorts by target descending', () {
      expect(sortedNames(SortOption.targetTertinggi), [
        'Beta',
        'Charlie',
        'Alpha',
      ]);
    });

    test('progressTerendah sorts by progress ascending', () {
      // Beta 10%, Charlie 50%, Alpha 90%
      expect(sortedNames(SortOption.progressTerendah), [
        'Beta',
        'Charlie',
        'Alpha',
      ]);
    });

    test('progressTertinggi sorts by progress descending', () {
      expect(sortedNames(SortOption.progressTertinggi), [
        'Alpha',
        'Charlie',
        'Beta',
      ]);
    });
  });

  group('combined search + filter + sort', () {
    final items = [
      makeItem(id: '1', name: 'Laptop Kerja', target: 1000, saved: 600),
      makeItem(id: '2', name: 'Laptop Gaming', target: 2000, saved: 1900),
      makeItem(id: '3', name: 'Laptop Tua', target: 1000, saved: 100),
      makeItem(id: '4', name: 'Sepatu', target: 1000, saved: 800),
    ];

    test('search "Laptop" + filter sedangBerjalan', () {
      final result = applyFilters(
        items: items,
        query: 'Laptop',
        filter: FilterOption.sedangBerjalan,
        sort: SortOption.namaAz,
      );
      expect(result.length, 2);
      expect(result.map((e) => e.name), ['Laptop Gaming', 'Laptop Kerja']);
    });

    test('search + filter yielding no results', () {
      final result = applyFilters(
        items: items,
        query: 'Sepatu',
        filter: FilterOption.tercapai,
        sort: SortOption.terbaru,
      );
      expect(result, isEmpty);
    });
  });

  group('WishlistStats', () {
    test('computes zeros for empty list', () {
      final stats = WishlistStats.compute([]);
      expect(stats.totalItems, 0);
      expect(stats.completedItems, 0);
      expect(stats.totalTarget, 0);
      expect(stats.totalSaved, 0);
      expect(stats.overallProgress, 0.0);
      expect(stats.totalRemaining, 0);
    });

    test('aggregates totals correctly', () {
      final stats = WishlistStats.compute([
        makeItem(id: '1', name: 'A', target: 1000, saved: 500),
        makeItem(id: '2', name: 'B', target: 3000, saved: 1000),
      ]);
      expect(stats.totalItems, 2);
      expect(stats.totalTarget, 4000);
      expect(stats.totalSaved, 1500);
      expect(stats.totalRemaining, 2500);
      expect(stats.overallProgress, 0.375);
    });

    test('counts completed items', () {
      final stats = WishlistStats.compute([
        makeItem(id: '1', name: 'A', target: 1000, saved: 1000),
        makeItem(id: '2', name: 'B', target: 1000, saved: 1200),
        makeItem(id: '3', name: 'C', target: 1000, saved: 400),
      ]);
      expect(stats.completedItems, 2);
    });

    test('overallProgress clamps to 1.0', () {
      final stats = WishlistStats.compute([
        makeItem(id: '1', name: 'A', target: 1000, saved: 5000),
      ]);
      expect(stats.overallProgress, 1.0);
    });

    test('totalRemaining never negative', () {
      final stats = WishlistStats.compute([
        makeItem(id: '1', name: 'A', target: 1000, saved: 5000),
      ]);
      expect(stats.totalRemaining, 0);
    });
  });

  group('formatDate', () {
    test('formats Indonesian month name', () {
      expect(formatDate(DateTime(2026, 8, 20)), '20 Agustus 2026');
    });

    test('formats January correctly', () {
      expect(formatDate(DateTime(2025, 1, 5)), '5 Januari 2025');
    });

    test('formats December correctly', () {
      expect(formatDate(DateTime(2025, 12, 31)), '31 Desember 2025');
    });
  });
}
