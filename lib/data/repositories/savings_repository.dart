import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/savings_entry.dart';
import '../../services/hive_service.dart';

class SavingsRepository {
  Box<SavingsEntry> get _box => HiveService.getSavingsBox();

  ValueListenable<Box<SavingsEntry>> get listenable => _box.listenable();

  List<SavingsEntry> getForWishlist(String wishlistId) {
    final entries = _box.values.where((e) => e.wishlistId == wishlistId).toList();
    entries.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    log('[Hive] getForWishlist $wishlistId: ${entries.length} entries');
    return entries;
  }

  Future<void> add(SavingsEntry entry) async {
    log('[Hive] add savings entry: ${entry.id} for ${entry.wishlistId}, amount=${entry.amount}');
    await _box.put(entry.id, entry);
    await _box.flush();
  }

  Future<void> deleteForWishlist(String wishlistId) async {
    log('[Hive] deleteForWishlist $wishlistId');
    final keys = _box.values
        .where((e) => e.wishlistId == wishlistId)
        .map((e) => e.id)
        .toList();
    await _box.deleteAll(keys);
    await _box.flush();
  }
}
