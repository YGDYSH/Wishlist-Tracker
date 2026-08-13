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
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
