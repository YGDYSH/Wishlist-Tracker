import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/wishlist_item.dart';
import '../helpers.dart';
import 'status_badge.dart';

class WishlistCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback? onTap;

  const WishlistCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final reach = item.isTargetReached;
    final target = item.targetPrice ?? 0;
    final remaining = item.remainingAmount;
    final overdue = item.isOverdue();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.imageUrl != null) ...[
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      child: buildWishlistImage(
                        item.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.surfaceVariant,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacingSm),
                ],
                Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 16),
                    ),
                  ),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: AppDimens.spacingSm),
              Wrap(
                spacing: AppDimens.spacingSm,
                runSpacing: AppDimens.spacingXs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _CategoryChip(label: item.category.label),
                  if (item.targetDate != null)
                    Text(
                      'Target: ${formatDate(item.targetDate!)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: overdue ? FontWeight.w700 : FontWeight.w500,
                        color: overdue
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  if (overdue)
                    const Text(
                      'Target terlewat',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimens.spacingSm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    Formatters.currency(item.savedAmount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '/',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Text(
                    Formatters.currency(target),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.progressFraction,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceVariant,
                        color: reach ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.spacingSm),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${item.progressPercentage.toStringAsFixed(0)}%',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.spacingSm),
              Text(
                reach
                    ? 'Target tercapai!'
                    : '${Formatters.currency(remaining)} lagi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: reach ? AppColors.secondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
