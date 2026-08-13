import 'package:hive/hive.dart';

part 'wishlist_item.g.dart';

enum WishlistStatus { mulaiMenabung, sedangBerjalan, targetTercapai }

@HiveType(typeId: 1)
enum WishlistCategory {
  @HiveField(0)
  elektronik,
  @HiveField(1)
  fashion,
  @HiveField(2)
  gaming,
  @HiveField(3)
  pendidikan,
  @HiveField(4)
  kendaraan,
  @HiveField(5)
  lainnya,
}

extension WishlistCategoryX on WishlistCategory {
  String get label {
    switch (this) {
      case WishlistCategory.elektronik:
        return 'Elektronik';
      case WishlistCategory.fashion:
        return 'Fashion';
      case WishlistCategory.gaming:
        return 'Gaming';
      case WishlistCategory.pendidikan:
        return 'Pendidikan';
      case WishlistCategory.kendaraan:
        return 'Kendaraan';
      case WishlistCategory.lainnya:
        return 'Lainnya';
    }
  }
}

@HiveType(typeId: 0)
class WishlistItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String? imageUrl;

  @HiveField(4)
  double? targetPrice;

  @HiveField(5)
  bool isPurchased;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  double savedAmount;

  // Nullable so records saved before this field existed still load correctly.
  @HiveField(8)
  WishlistCategory? categoryOrNull;

  @HiveField(9)
  DateTime? targetDate;

  WishlistItem({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl,
    this.targetPrice,
    this.isPurchased = false,
    this.savedAmount = 0.0,
    WishlistCategory? category,
    this.targetDate,
    DateTime? createdAt,
  }) : categoryOrNull = category,
       createdAt = createdAt ?? DateTime.now();

  WishlistCategory get category => categoryOrNull ?? WishlistCategory.lainnya;

  set category(WishlistCategory value) => categoryOrNull = value;

  double get progressFraction {
    if (targetPrice == null || targetPrice! <= 0) return 0.0;
    final progress = savedAmount / targetPrice!;
    return progress.clamp(0.0, 1.0);
  }

  double get progressPercentage {
    return progressFraction * 100;
  }

  WishlistStatus get status {
    if (isTargetReached) return WishlistStatus.targetTercapai;
    if (progressFraction >= 0.5) return WishlistStatus.sedangBerjalan;
    return WishlistStatus.mulaiMenabung;
  }

  String get statusLabel {
    switch (status) {
      case WishlistStatus.mulaiMenabung:
        return 'Mulai Menabung';
      case WishlistStatus.sedangBerjalan:
        return 'Sedang Berjalan';
      case WishlistStatus.targetTercapai:
        return 'Target Tercapai';
    }
  }

  double get remainingAmount {
    if (targetPrice == null) return 0.0;
    final remaining = targetPrice! - savedAmount;
    return remaining > 0 ? remaining : 0.0;
  }

  bool get isTargetReached {
    return targetPrice != null && savedAmount >= targetPrice!;
  }

  bool isOverdue({DateTime? now}) {
    if (targetDate == null) return false;
    if (isTargetReached) return false;
    final reference = now ?? DateTime.now();
    return targetDate!.isBefore(
      DateTime(reference.year, reference.month, reference.day),
    );
  }

  String? deadlineLabel({DateTime? now}) {
    if (targetDate == null) return null;
    if (isTargetReached) return 'Target tercapai';
    if (isOverdue(now: now)) return 'Target terlewat';
    return null;
  }
}
