import 'dart:developer';
import 'package:hive/hive.dart';
import '../data/models/wishlist_item.dart';
import '../data/repositories/api_repository.dart';
import '../data/repositories/wishlist_repository.dart';
import 'session_service.dart';

/// Two-way sync between local Hive and the PHP API.
///
/// Local writes are first saved to Hive, then recorded in a pending-sync
/// queue (a plain Hive box of maps). A background sync push flushes that
/// queue to the server whenever possible. Pulling happens from the API on
/// the home screen; items that only exist remotely are imported locally so
/// both stores converge.
class SyncService {
  SyncService._();

  static const String _boxName = 'sync_queue';

  static Future<Box> _openBox() async {
    return Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
  }

  // --- Queueing ------------------------------------------------------------

  /// Records a pending sync operation. `op` is 'upsert' or 'delete'.
  static Future<void> enqueue({
    required String op,
    required WishlistItem item,
  }) async {
    final box = await _openBox();
    await box.put(item.id, {
      'op': op,
      'name': item.name,
      'description': item.description,
      'imageUrl': item.imageUrl,
      'targetPrice': item.targetPrice,
      'savedAmount': item.savedAmount,
      'category': item.category.label,
      'targetDate': item.targetDate?.toIso8601String(),
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    log('[Sync] enqueue ${item.id}: $op');
  }

  static Future<void> enqueueDelete(String itemId) async {
    final box = await _openBox();
    await box.put(itemId, {'op': 'delete', 'updatedAt': DateTime.now().toIso8601String()});
    log('[Sync] enqueue delete $itemId');
  }

  static Future<void> remove(String itemId) async {
    final box = await _openBox();
    await box.delete(itemId);
  }

  static Future<int> pendingCount() async {
    final box = await _openBox();
    return box.length;
  }

  // --- Push -----------------------------------------------------------------

  /// Attempts to flush all pending local changes to the server.
  /// Returns [true] if every queued op succeeded (or queue was empty).
  static Future<bool> pushAll() async {
    final userId = SessionService.userId;
    if (userId == null) return false;

    final box = await _openBox();
    if (box.isEmpty) return true;

    var allOk = true;
    for (final key in box.keys.toList()) {
      final entry = box.get(key);
      if (entry == null) continue;

      try {
        if (entry['op'] == 'delete') {
          await ApiRepository.deleteWishlist(userId: userId, itemId: key);
        } else {
          final item = _wishlistFromQueue(key, entry);
          await ApiRepository.saveWishlist(userId: userId, item: item);
        }
        await box.delete(key);
      } catch (e) {
        log('[Sync] push failed for $key: $e');
        allOk = false;
        break; // stop on first failure; will retry later
      }
    }
    return allOk;
  }

  // --- Merge -----------------------------------------------------------------

  /// Imports remote items into local Hive (upsert). Keeps locally-edited
  /// pending items untouched so they are not overwritten before syncing.
  static Future<void> mergeRemote(List<WishlistItem> remote) async {
    final repo = WishlistRepository();
    final box = await _openBox();
    final pendingIds = box.keys.toSet();

    for (final remoteItem in remote) {
      if (pendingIds.contains(remoteItem.id)) continue; // local pending wins
      final local = repo.getById(remoteItem.id);
      if (local == null) {
        await repo.add(remoteItem);
      } else if (remoteItem.createdAt.isAfter(local.createdAt)) {
        await repo.update(remoteItem);
      }
    }
  }

  static WishlistItem _wishlistFromQueue(String id, Map<dynamic, dynamic> entry) {
    final categoryLabel = entry['category'] as String? ?? 'Lainnya';
    WishlistCategory category;
    switch (categoryLabel.toLowerCase()) {
      case 'elektronik': category = WishlistCategory.elektronik; break;
      case 'fashion': category = WishlistCategory.fashion; break;
      case 'gaming': category = WishlistCategory.gaming; break;
      case 'pendidikan': category = WishlistCategory.pendidikan; break;
      case 'kendaraan': category = WishlistCategory.kendaraan; break;
      default: category = WishlistCategory.lainnya;
    }

    return WishlistItem(
      id: id,
      name: entry['name'] as String? ?? '',
      description: entry['description'] as String? ?? '',
      imageUrl: entry['imageUrl'] as String?,
      targetPrice: (entry['targetPrice'] as num?)?.toDouble(),
      savedAmount: (entry['savedAmount'] as num?)?.toDouble() ?? 0.0,
      category: category,
      targetDate: DateTime.tryParse(entry['targetDate'] as String? ?? ''),
      createdAt: DateTime.tryParse(entry['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}