import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/wishlist_item.dart';
import '../../../data/models/savings_entry.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../data/repositories/savings_repository.dart';
import '../../../services/notification_service.dart';
import '../helpers.dart';
import '../widgets/add_funds_sheet.dart';
import '../widgets/status_badge.dart';
import 'wishlist_form_screen.dart';

class WishlistDetailScreen extends StatefulWidget {
  final WishlistRepository repository;
  final WishlistItem item;

  const WishlistDetailScreen({
    super.key,
    required this.repository,
    required this.item,
  });

  @override
  State<WishlistDetailScreen> createState() => _WishlistDetailScreenState();
}

class _WishlistDetailScreenState extends State<WishlistDetailScreen> {
  late WishlistItem _item;
  final _savingsRepo = SavingsRepository();

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  void _refreshItem() {
    final updated = widget.repository.getById(_item.id);
    if (updated != null && mounted) {
      setState(() => _item = updated);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAddFundsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFundsSheet(
        item: _item,
        onAdded: (added) {
          _showSnackBar(
            'Dana berhasil ditambahkan ${Formatters.currency(added)}',
          );
        },
        onDismissed: _refreshItem,
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Wishlist'),
        content: Text(
          'Yakin ingin menghapus "${_item.name}"?\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              widget.repository.delete(_item.id);
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => WishlistFormScreen(
          repository: widget.repository,
          existingItem: _item,
        ),
      ),
    );
    _refreshItem();
    if (result == true && mounted) {
      _showSnackBar('Wishlist berhasil diperbarui');
    }
  }

  void _duplicateItem() async {
    final newItem = _item.copyForDuplicate(const Uuid().v4());
    await widget.repository.add(newItem);
    if (mounted) {
      NotificationService.rescheduleAllReminders();
    }
    _showSnackBar('Wishlist "${newItem.name}" berhasil diduplikat');
  }

  @override
  Widget build(BuildContext context) {
    final reach = _item.isTargetReached;

    return Scaffold(
      appBar: AppBar(
        title: Text(_item.name),
actions: [
            IconButton(
              onPressed: _navigateToEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
            ),
            IconButton(
              onPressed: _duplicateItem,
              icon: const Icon(Icons.copy_outlined),
              tooltip: 'Duplikat',
            ),
            const SizedBox(width: 4),
          ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: buildWishlistImage(
                  _item.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppDimens.spacingLg),
            ],
            _ProgressCard(item: _item),
            const SizedBox(height: AppDimens.spacingLg),
            FilledButton.icon(
              onPressed: reach ? null : _showAddFundsSheet,
              icon: const Icon(Icons.savings_outlined),
              label: const Text('Tambah Dana'),
              style: FilledButton.styleFrom(
                backgroundColor: reach
                    ? AppColors.textSecondary
                    : AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimens.spacingMd),
            OutlinedButton.icon(
              onPressed: _navigateToEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Wishlist'),
            ),
            const SizedBox(height: AppDimens.spacingMd),
            TextButton.icon(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus Wishlist'),
            ),
            const SizedBox(height: AppDimens.spacingLg),
            _DetailInfo(item: _item),
            const SizedBox(height: AppDimens.spacingLg),
            _SavingsHistory(
              entries: _savingsRepo.getForWishlist(_item.id),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final WishlistItem item;

  const _ProgressCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final reach = item.isTargetReached;
    final target = item.targetPrice ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingXl),
        child: Column(
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: item.progressFraction,
                      strokeWidth: 14,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: reach ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${item.progressPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'tercapai',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.spacingMd),
            StatusBadge(status: item.status),
            const SizedBox(height: AppDimens.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _MoneyTile(
                    label: 'Dana',
                    value: Formatters.currency(item.savedAmount),
                    color: AppColors.secondary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: colorScheme.surfaceContainerHighest,
                ),
                Expanded(
                  child: _MoneyTile(
                    label: 'Sisa',
                    value: Formatters.currency(item.remainingAmount),
                    color: reach
                        ? AppColors.secondary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: colorScheme.surfaceContainerHighest,
                ),
                Expanded(
                  child: _MoneyTile(
                    label: 'Target',
                    value: Formatters.currency(target),
                    color: AppColors.primary,
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

class _MoneyTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MoneyTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _DetailInfo extends StatelessWidget {
  final WishlistItem item;

  const _DetailInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppDimens.spacingMd),
            _InfoRow(label: 'Nama Barang', value: item.name),
            const SizedBox(height: AppDimens.spacingMd),
            _InfoRow(label: 'Kategori', value: item.category.label),
            const SizedBox(height: AppDimens.spacingMd),
            _InfoRow(
              label: 'Target Harga',
              value: item.targetPrice != null
                  ? Formatters.currency(item.targetPrice!)
                  : '-',
            ),
            const SizedBox(height: AppDimens.spacingMd),
            _InfoRow(
              label: 'Dana Terkumpul',
              value: Formatters.currency(item.savedAmount),
            ),
            const SizedBox(height: AppDimens.spacingMd),
            _InfoRow(
              label: 'Sisa Dana',
              value: Formatters.currency(item.remainingAmount),
            ),
            const SizedBox(height: AppDimens.spacingMd),
            _InfoRow(
              label: 'Persentase',
              value: '${item.progressPercentage.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: AppDimens.spacingMd),
            _InfoRow(
              label: 'Status',
              value: item.statusLabel,
              valueColor: item.isTargetReached
                  ? AppColors.secondary
                  : AppColors.primary,
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: AppDimens.spacingMd),
              _InfoRow(
                label: 'Catatan',
                value: item.description,
                isMultiline: true,
              ),
            ],
            const SizedBox(height: AppDimens.spacingMd),
            if (item.targetDate != null)
              _InfoRow(
                label: 'Target Tanggal',
                value: 'Target: ${formatDate(item.targetDate!)}',
              ),
            if (item.targetDate != null && item.isOverdue()) ...[
              const SizedBox(height: AppDimens.spacingMd),
              _InfoRow(
                label: 'Status Tanggal',
                value: 'Target terlewat',
                valueColor: AppColors.error,
              ),
            ],
            const SizedBox(height: AppDimens.spacingMd),
            _InfoRow(
              label: 'Dibuat pada',
              value:
                  '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiline;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isMultiline = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          ': ',
          style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? colorScheme.onSurface,
            ),
            maxLines: isMultiline ? 4 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SavingsHistory extends StatelessWidget {
  final List<SavingsEntry> entries;
  static const _previewLimit = 5;

  const _SavingsHistory({required this.entries});

  void _showAllEntries(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppDimens.spacingSm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.spacingLg),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimens.spacingSm),
                    const Text(
                      'Semua Riwayat Dana',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${entries.length} transaksi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spacingLg,
                    vertical: AppDimens.spacingSm,
                  ),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      _buildEntryTile(context, entries[i], entries.length - i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildEntryTile(
    BuildContext context,
    SavingsEntry e,
    int count,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.spacingSm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '#$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Formatters.currency(e.amount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${e.formattedDate} • ${e.formattedTime}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = entries.take(_previewLimit).toList();
    final hasMore = entries.length > _previewLimit;

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: AppDimens.spacingLg),
          childrenPadding: const EdgeInsets.only(
            left: AppDimens.spacingLg,
            right: AppDimens.spacingLg,
            bottom: AppDimens.spacingLg,
          ),
          leading: const Icon(Icons.history, size: 18, color: AppColors.primary),
          title: Row(
            children: [
              const Text(
                'Riwayat Dana',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppDimens.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                ),
                child: Text(
                  '${entries.length}x',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          children: [
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.spacingMd,
                ),
                child: Center(
                  child: Text(
                    'Belum ada riwayat penambahan dana',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              ...List.generate(preview.length, (i) {
                final e = preview[i];
                final count = entries.length - i;
                return Column(
                  children: [
                    _buildEntryTile(context, e, count),
                    if (i < preview.length - 1) const Divider(height: 1),
                  ],
                );
              }),
              if (hasMore) ...[
                const Divider(height: 1),
                const SizedBox(height: AppDimens.spacingSm),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showAllEntries(context),
                    icon: const Icon(Icons.expand_more, size: 18),
                    label: Text(
                      'Lihat semua (${entries.length} transaksi)',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
