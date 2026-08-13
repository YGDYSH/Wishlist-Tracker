import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/formatters.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../helpers.dart';

class StatisticsScreen extends StatelessWidget {
  final WishlistRepository repository;

  const StatisticsScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: repository.listenable,
          builder: (context, box, child) {
            final stats = WishlistStats.compute(repository.getAll());
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Overall progress
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.spacingXl),
                      child: Column(
                        children: [
                          Text(
                            'Progress Keseluruhan',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppDimens.spacingLg),
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: stats.overallProgress,
                                    strokeWidth: 12,
                                    backgroundColor: AppColors.surfaceVariant,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(stats.overallProgress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const Text(
                                      'dana tercapai',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingMd),
                  _StatItem(
                    label: 'Total Wishlist',
                    value: '${stats.totalItems}',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimens.spacingSm),
                  _StatItem(
                    label: 'Total Target Harga',
                    value: Formatters.currency(stats.totalTarget),
                    icon: Icons.flag_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimens.spacingSm),
                  _StatItem(
                    label: 'Total Dana Terkumpul',
                    value: Formatters.currency(stats.totalSaved),
                    icon: Icons.savings_outlined,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: AppDimens.spacingSm),
                  _StatItem(
                    label: 'Dana Masih Dibutuhkan',
                    value: Formatters.currency(stats.totalRemaining),
                    icon: Icons.remove_circle_outline,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppDimens.spacingSm),
                  _StatItem(
                    label: 'Wishlist Tercapai',
                    value: '${stats.completedItems}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingMd),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppDimens.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color == AppColors.error
                          ? AppColors.textPrimary
                          : color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
