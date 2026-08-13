import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/wishlist_item.dart';
import '../../data/models/savings_entry.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/repositories/savings_repository.dart';
import '../../services/notification_service.dart';

class AddFundsSheet extends StatefulWidget {
  final WishlistItem item;
  final ValueChanged<double>? onAdded;
  final VoidCallback? onDismissed;

  const AddFundsSheet({
    super.key,
    required this.item,
    this.onAdded,
    this.onDismissed,
  });

  @override
  State<AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<AddFundsSheet> {
  final _controller = TextEditingController();
  final _repo = WishlistRepository();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final amount = double.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) return;

    final maxAllowed = widget.item.targetPrice != null
        ? widget.item.targetPrice! - widget.item.savedAmount
        : double.infinity;
    final finalAmount = amount.clamp(0.0, maxAllowed);

    widget.item.savedAmount += finalAmount;
    _repo.update(widget.item);
    SavingsRepository().add(
      SavingsEntry(
        id: const Uuid().v4(),
        wishlistId: widget.item.id,
        amount: finalAmount,
        addedAt: DateTime.now(),
      ),
    );
    NotificationService.rescheduleAllReminders();
    widget.onAdded?.call(finalAmount);
    widget.onDismissed?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final maxAdditional = widget.item.targetPrice != null
        ? widget.item.targetPrice! - widget.item.savedAmount
        : 0.0;
    final maxText = Formatters.currency(maxAdditional);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        top: AppDimens.spacingMd,
        left: AppDimens.spacingLg,
        right: AppDimens.spacingLg,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppDimens.spacingMd),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              'Tambah Dana',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimens.spacingSm),
            Text(
              'Terkumpul saat ini: ${Formatters.currency(widget.item.savedAmount)}',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.item.targetPrice != null && maxAdditional > 0) ...[
              Text(
                'Sisa target: $maxText',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppDimens.spacingMd),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                hintText: '0',
                labelText: 'Nominal dana tambahan',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: AppDimens.spacingLg),
            FilledButton(onPressed: _add, child: const Text('Tambah Dana')),
            const SizedBox(height: AppDimens.spacingSm),
          ],
        ),
      ),
    );
  }
}
