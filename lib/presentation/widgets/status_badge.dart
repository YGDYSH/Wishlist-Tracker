import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/wishlist_item.dart';

class StatusBadge extends StatelessWidget {
  final WishlistStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case WishlistStatus.mulaiMenabung:
        color = AppColors.textSecondary;
        label = 'Mulai Menabung';
      case WishlistStatus.sedangBerjalan:
        color = AppColors.primary;
        label = 'Sedang Berjalan';
      case WishlistStatus.targetTercapai:
        color = AppColors.secondary;
        label = 'Target Tercapai';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
