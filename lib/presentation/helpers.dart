import 'dart:io' as io;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../data/models/wishlist_item.dart';

enum FilterOption { all, belumTercapai, sedangBerjalan, tercapai }

enum SortOption {
  terbaru,
  namaAz,
  namaZa,
  targetTerendah,
  targetTertinggi,
  progressTerendah,
  progressTertinggi,
}

extension FilterOptionX on FilterOption {
  String get label {
    switch (this) {
      case FilterOption.all:
        return 'Semua';
      case FilterOption.belumTercapai:
        return 'Belum Tercapai';
      case FilterOption.sedangBerjalan:
        return 'Sedang Berjalan';
      case FilterOption.tercapai:
        return 'Tercapai';
    }
  }
}

extension SortOptionX on SortOption {
  String get label {
    switch (this) {
      case SortOption.terbaru:
        return 'Terbaru';
      case SortOption.namaAz:
        return 'Nama A-Z';
      case SortOption.namaZa:
        return 'Nama Z-A';
      case SortOption.targetTerendah:
        return 'Target Terendah';
      case SortOption.targetTertinggi:
        return 'Target Tertinggi';
      case SortOption.progressTerendah:
        return 'Progress Terendah';
      case SortOption.progressTertinggi:
        return 'Progress Tertinggi';
    }
  }
}

List<WishlistItem> applyFilters({
  required List<WishlistItem> items,
  required String query,
  required FilterOption filter,
  required SortOption sort,
  DateTime? now,
}) {
  final q = query.trim().toLowerCase();

  var result = items.where((item) {
    if (q.isNotEmpty) {
      final nameMatch = item.name.toLowerCase().contains(q);
      final descMatch = item.description.toLowerCase().contains(q);
      final catMatch = item.category.label.toLowerCase().contains(q);
      if (!nameMatch && !descMatch && !catMatch) return false;
    }

    switch (filter) {
      case FilterOption.all:
        break;
      case FilterOption.belumTercapai:
        if (item.isTargetReached) return false;
        if (item.status == WishlistStatus.sedangBerjalan) return false;
        break;
      case FilterOption.sedangBerjalan:
        if (item.status != WishlistStatus.sedangBerjalan) return false;
        break;
      case FilterOption.tercapai:
        if (!item.isTargetReached) return false;
        break;
    }

    return true;
  }).toList();

  switch (sort) {
    case SortOption.terbaru:
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case SortOption.namaAz:
      result.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    case SortOption.namaZa:
      result.sort(
        (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
      );
    case SortOption.targetTerendah:
      result.sort((a, b) => (a.targetPrice ?? 0).compareTo(b.targetPrice ?? 0));
    case SortOption.targetTertinggi:
      result.sort((a, b) => (b.targetPrice ?? 0).compareTo(a.targetPrice ?? 0));
    case SortOption.progressTerendah:
      result.sort((a, b) => a.progressFraction.compareTo(b.progressFraction));
    case SortOption.progressTertinggi:
      result.sort((a, b) => b.progressFraction.compareTo(a.progressFraction));
  }

  return result;
}

class WishlistStats {
  final int totalItems;
  final int completedItems;
  final double totalTarget;
  final double totalSaved;
  final double overallProgress;

  const WishlistStats({
    required this.totalItems,
    required this.completedItems,
    required this.totalTarget,
    required this.totalSaved,
    required this.overallProgress,
  });

  double get totalRemaining {
    final diff = totalTarget - totalSaved;
    return diff > 0 ? diff : 0.0;
  }

  static WishlistStats compute(List<WishlistItem> items) {
    int completed = 0;
    double target = 0;
    double saved = 0;
    for (final item in items) {
      if (item.isTargetReached) completed++;
      target += item.targetPrice ?? 0;
      saved += item.savedAmount;
    }
    final progress = target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;
    return WishlistStats(
      totalItems: items.length,
      completedItems: completed,
      totalTarget: target,
      totalSaved: saved,
      overallProgress: progress,
    );
  }
}

Widget buildWishlistImage(
  String? path, {
  double? height,
  double? width,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
}) {
  if (path == null || path.isEmpty) return const SizedBox.shrink();

  if (path.startsWith('data:image')) {
    final base64String = path.split(',').last;
    return Image.memory(
      base64Decode(base64String),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: errorBuilder ?? (_, _, _) => const SizedBox.shrink(),
    );
  }

  if (!kIsWeb) {
    return Image.file(
      io.File(path),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: errorBuilder ?? (_, _, _) => const SizedBox.shrink(),
    );
  }

  return const SizedBox.shrink();
}

String formatDate(DateTime date) {
  final months = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${date.day} ${months[date.month]} ${date.year}';
}
