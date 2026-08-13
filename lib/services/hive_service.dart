import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/wishlist_item.dart';
import '../data/models/savings_entry.dart';
import 'session_service.dart';

class HiveService {
  static const String _wishlistBoxPrefix = 'wishlist_';
  static const String _savingsBoxPrefix = 'savings_';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(WishlistItemAdapter());
    Hive.registerAdapter(WishlistCategoryAdapter());
    Hive.registerAdapter(SavingsEntryAdapter());
  }

  static String _wishlistBoxName() => '$_wishlistBoxPrefix${SessionService.userId ?? "guest"}';
  static String _savingsBoxName() => '$_savingsBoxPrefix${SessionService.userId ?? "guest"}';

  static Future<void> openBoxesForCurrentUser() async {
    final wName = _wishlistBoxName();
    final sName = _savingsBoxName();
    if (!Hive.isBoxOpen(wName)) {
      await Hive.openBox<WishlistItem>(wName);
    }
    if (!Hive.isBoxOpen(sName)) {
      await Hive.openBox<SavingsEntry>(sName);
    }
  }

  static Box<WishlistItem> getWishlistBox() {
    return Hive.box<WishlistItem>(_wishlistBoxName());
  }

  static Box<SavingsEntry> getSavingsBox() {
    return Hive.box<SavingsEntry>(_savingsBoxName());
  }
}