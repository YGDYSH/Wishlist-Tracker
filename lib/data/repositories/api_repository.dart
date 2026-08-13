import '../models/wishlist_item.dart';
import '../../services/api_service.dart';

/// Fetches wishlists from the PHP API and maps them onto [WishlistItem]
/// so the existing UI widgets can be reused.
///
/// Hive remains the offline store; this repository introduces the API as an
/// optional online source without replacing CRUD yet.
class ApiRepository {
  ApiRepository._();

  static WishlistCategory _mapCategory(String? value) {
    if (value == null || value.isEmpty) return WishlistCategory.lainnya;
    switch (value.toLowerCase()) {
      case 'elektronik':
        return WishlistCategory.elektronik;
      case 'fashion':
        return WishlistCategory.fashion;
      case 'gaming':
        return WishlistCategory.gaming;
      case 'pendidikan':
        return WishlistCategory.pendidikan;
      case 'kendaraan':
        return WishlistCategory.kendaraan;
      default:
        return WishlistCategory.lainnya;
    }
  }

  static WishlistItem _fromApiJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      final n = double.tryParse('$v');
      return n ?? 0;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null || '$v'.isEmpty) return null;
      return DateTime.tryParse('$v');
    }

    return WishlistItem(
      id: 'api_${json['id']}',
      name: (json['name'] as String?) ?? '',
      description: (json['notes'] as String?) ?? '',
      targetPrice: parseDouble(json['target_price']),
      savedAmount: parseDouble(json['saved_amount']),
      category: _mapCategory(json['category'] as String?),
      targetDate: parseDate(json['target_date']),
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  /// Loads the wishlist from the API for a given logged-in [userId].
  static Future<List<WishlistItem>> getWishlists(int userId) async {
    final result = await ApiService.getWishlists(userId);
    if (!result.success) {
      throw ApiException(result.message);
    }
    final rows = result.data ?? const [];
    return rows.map(_fromApiJson).toList();
  }

  /// Pushes a local wishlist item to the server.
  static Future<void> saveWishlist({
    required int userId,
    required WishlistItem item,
  }) async {
    final result = await ApiService.saveWishlist(
      userId: userId,
      item: _toApiJson(item),
    );
    if (!result.success) {
      throw ApiException(result.message);
    }
  }

  /// Deletes a wishlist item on the server.
  static Future<void> deleteWishlist({
    required int userId,
    required String itemId,
  }) async {
    final result = await ApiService.deleteWishlist(
      userId: userId,
      itemId: itemId,
    );
    if (!result.success) {
      throw ApiException(result.message);
    }
  }

  static Map<String, dynamic> _toApiJson(WishlistItem item) {
    String? dateToString(DateTime? date) => date?.toIso8601String();

    return {
      'id': item.id.startsWith('api_') ? item.id.substring(4) : item.id,
      'name': item.name,
      'notes': item.description,
      'target_price': item.targetPrice ?? 0,
      'saved_amount': item.savedAmount,
      'category': item.category.label.toLowerCase(),
      'target_date': dateToString(item.targetDate),
      'created_at': item.createdAt.toIso8601String(),
    };
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
