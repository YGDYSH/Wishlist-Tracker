import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/wishlist_item.dart';
import '../../services/hive_service.dart';
import '../../services/sync_service.dart';
import 'savings_repository.dart';

class WishlistRepository {
  Box<WishlistItem> get _box => HiveService.getWishlistBox();

  ValueListenable<Box<WishlistItem>> get listenable => _box.listenable();

  List<WishlistItem> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    log('[Hive] getAll: ${items.length} items, box path: ${_box.path}');
    return items;
  }

  Future<void> add(WishlistItem item) async {
    log(
      '[Hive] add: ${item.id} - ${item.name}, savedAmount=${item.savedAmount}',
    );
    await _box.put(item.id, item);
    await _box.flush();
    await SyncService.enqueue(op: 'upsert', item: item);
    log('[Hive] add done. box count: ${_box.length}');
  }

  Future<void> update(WishlistItem item) async {
    log('[Hive] update: ${item.id} - ${item.name}');
    await _box.put(item.id, item);
    await _box.flush();
    await SyncService.enqueue(op: 'upsert', item: item);
    log('[Hive] update done. box count: ${_box.length}');
  }

  Future<void> delete(String id) async {
    log('[Hive] delete: $id');
    await _box.delete(id);
    await SavingsRepository().deleteForWishlist(id);
    await _box.flush();
    await SyncService.enqueueDelete(id);
    log('[Hive] delete done. box count: ${_box.length}');
  }

  WishlistItem? getById(String id) {
    final item = _box.get(id);
    log('[Hive] getById: $id -> ${item == null ? "null" : item.id}');
    return item;
  }

  Map<String, double> getSummary() {
    final items = getAll();
    double totalTarget = 0;
    double totalSaved = 0;
    for (final item in items) {
      if (item.targetPrice != null) {
        totalTarget += item.targetPrice!;
      }
      totalSaved += item.savedAmount;
    }
    final totalRemaining = (totalTarget - totalSaved).clamp(
      0.0,
      double.infinity,
    );
    log(
      '[Hive] summary: items=${items.length}, target=$totalTarget, saved=$totalSaved, remaining=$totalRemaining',
    );
    return {
      'count': items.length.toDouble(),
      'totalTarget': totalTarget,
      'totalSaved': totalSaved,
      'totalRemaining': totalRemaining,
    };
  }
}
