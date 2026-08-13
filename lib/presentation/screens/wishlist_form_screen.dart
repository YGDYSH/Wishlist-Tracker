import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../data/models/wishlist_item.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../helpers.dart';

class WishlistFormScreen extends StatefulWidget {
  final WishlistRepository repository;
  final WishlistItem? existingItem;

  const WishlistFormScreen({
    super.key,
    required this.repository,
    this.existingItem,
  });

  @override
  State<WishlistFormScreen> createState() => _WishlistFormScreenState();
}

class _WishlistFormScreenState extends State<WishlistFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _targetPriceController;
  late final TextEditingController _savedAmountController;
  late final TextEditingController _descriptionController;
  late WishlistCategory _category;
  DateTime? _targetDate;
  String? _imagePath;

  bool get isEditMode => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _targetPriceController = TextEditingController(
      text: item?.targetPrice?.toString() ?? '',
    );
    _savedAmountController = TextEditingController(
      text: item?.savedAmount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    _category = item?.category ?? WishlistCategory.lainnya;
    _targetDate = item?.targetDate;
    _imagePath = item?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetPriceController.dispose();
    _savedAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        String? savedPath;

        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          savedPath = 'data:image/png;base64,${base64Encode(bytes)}';
        } else {
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
          final savedFile = await File(
            picked.path,
          ).copy('${appDir.path}/$fileName');
          savedPath = savedFile.path;
        }

        setState(() => _imagePath = savedPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  bool _saving = false;

  Future<void> _saveItem() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final targetPrice = double.parse(_targetPriceController.text.trim());
      final savedAmount =
          double.tryParse(_savedAmountController.text.trim()) ?? 0.0;

      if (isEditMode) {
        final item = widget.existingItem!;
        item.name = _nameController.text.trim();
        item.targetPrice = targetPrice;
        item.savedAmount = savedAmount;
        item.description = _descriptionController.text.trim();
        item.category = _category;
        item.targetDate = _targetDate;
        item.imageUrl = _imagePath;
        await widget.repository.update(item);
      } else {
        final newItem = WishlistItem(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          targetPrice: targetPrice,
          savedAmount: savedAmount,
          description: _descriptionController.text.trim(),
          category: _category,
          targetDate: _targetDate,
          imageUrl: _imagePath,
        );
        await widget.repository.add(newItem);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
      );
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama barang wajib diisi';
    }
    return null;
  }

  String? _targetPriceValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Target harga wajib diisi';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Masukkan angka valid';
    if (parsed <= 0) return 'Target harga harus lebih dari 0';
    return null;
  }

  /// Saved amount is optional on create; must be >= 0 and not exceed target.
  String? _savedAmountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Masukkan angka valid';
    if (parsed < 0) return 'Dana tidak boleh negatif';
    final target = double.tryParse(_targetPriceController.text.trim());
    if (target != null && target > 0 && parsed > target) {
      return 'Dana tidak boleh melebihi target';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Wishlist' : 'Tambah Wishlist'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePickerField(),
                const SizedBox(height: AppDimens.spacingLg),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama barang',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: AppDimens.spacingMd),
                TextFormField(
                  controller: _targetPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Target harga',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _targetPriceValidator,
                ),
                const SizedBox(height: AppDimens.spacingMd),
                TextFormField(
                  controller: _savedAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah tabungan awal (opsional)',
                    hintText: '0',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: _savedAmountValidator,
                ),
                const SizedBox(height: AppDimens.spacingMd),
                _CategoryDropDown(
                  value: _category,
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: AppDimens.spacingMd),
                _buildDateField(),
                const SizedBox(height: AppDimens.spacingMd),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppDimens.spacingLg),
                FilledButton.icon(
                  onPressed: _saving ? null : _saveItem,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _saving
                        ? 'Menyimpan...'
                        : isEditMode
                        ? 'Simpan perubahan'
                        : 'Tambahkan',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    final label = _targetDate == null
        ? 'Tanggal target (opsional)'
        : 'Tanggal target: ${formatDate(_targetDate!)}';
    return GestureDetector(
      onTap: _pickTargetDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildImagePickerField() {
    final hasImage = _imagePath != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Barang (opsional)',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppDimens.spacingSm),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              border: Border.all(
                color: AppColors.primary.withAlpha(80),
                width: 1.5,
              ),
            ),
            child: hasImage
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
child: buildWishlistImage(
	                _imagePath,
	                height: 160,
	                width: double.infinity,
	                fit: BoxFit.cover,
	              ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () => setState(() => _imagePath = null),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppDimens.spacingSm),
                      const Text(
                        'Pilih Foto Barang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap untuk membuka galeri',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _CategoryDropDown extends StatelessWidget {
  final WishlistCategory value;
  final ValueChanged<WishlistCategory?> onChanged;

  const _CategoryDropDown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<WishlistCategory>(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Kategori',
        prefixIcon: const Icon(Icons.category_outlined),
      ),
      items: WishlistCategory.values
          .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
          .toList(),
      validator: (v) {
        if (v == null) return 'Kategori wajib dipilih';
        return null;
      },
    );
  }
}
