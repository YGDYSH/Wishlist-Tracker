import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/wishlist_item.dart';

class DashboardSummary extends StatelessWidget {
  final List<WishlistItem> items;

  const DashboardSummary({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final count = items.length;
    double totalTarget = 0;
    double totalSaved = 0;
    for (final item in items) {
      totalTarget += item.targetPrice ?? 0;
      totalSaved += item.savedAmount;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimens.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: 'Wishlist',
                    value: '$count',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Terkumpul',
                    value: Formatters.currency(totalSaved),
                    icon: Icons.savings_outlined,
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Target',
                    value: Formatters.currency(totalTarget),
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Stat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(height: AppDimens.spacingSm),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimens.spacingXs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
