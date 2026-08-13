import 'package:flutter/material.dart';
import '../../core/constants/app_dimens.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.pagePadding,
        AppDimens.spacingSm,
        AppDimens.pagePadding,
        AppDimens.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wishlist Saya',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppDimens.spacingXs),
          Text(
            'Pantau target barang yang ingin kamu beli.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
