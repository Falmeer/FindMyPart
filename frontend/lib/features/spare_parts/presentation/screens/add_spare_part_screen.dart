import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/image_picker_grid.dart';
import '../../data/repositories/spare_parts_repository.dart';
import '../../providers/spare_parts_provider.dart';

class AddSparePartScreen extends ConsumerStatefulWidget {
  const AddSparePartScreen({super.key});

  @override
  ConsumerState<AddSparePartScreen> createState() => _AddSparePartScreenState();
}

class _AddSparePartScreenState extends ConsumerState<AddSparePartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _descController = TextEditingController();
  final _compatController = TextEditingController();
  String _condition = 'Used';
  int? _categoryId;
  bool _hasWarranty = false;
  bool _isLoading = false;
  List<PickedImage> _images = [];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descController.dispose();
    _compatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('List a Spare Part')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 24),
                Text('Part Details', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Part Name',
                  controller: _nameController,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                ref.watch(categoriesProvider).when(
                  data: (cats) => DropdownButtonFormField<int>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    hint: const Text('Select category'),
                    items: cats
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                    validator: (v) => v == null ? 'Category is required' : null,
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Could not load categories'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _condition,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  items: ['New', 'Used', 'Refurbished']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _condition = v!),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Price (BHD)',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Quantity',
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Compatible With (e.g. Toyota Camry 2018–2022)',
                  controller: _compatController,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Description (optional)',
                  controller: _descController,
                  maxLines: 4,
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  title: const Text('Includes Warranty'),
                  subtitle: const Text('Toggle if this part comes with a warranty'),
                  value: _hasWarranty,
                  onChanged: (v) => setState(() => _hasWarranty = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Post Part',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return ImagePickerGrid(
      images: _images,
      onChanged: (updated) => setState(() => _images = updated),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(sparePartsRepositoryProvider).createPart(
        fields: {
          'name': _nameController.text.trim(),
          'category_id': _categoryId!,
          'condition': _condition,
          'price': double.tryParse(_priceController.text.trim()) ?? 0,
          'quantity': int.tryParse(_quantityController.text.trim()) ?? 1,
          'description': _descController.text.trim(),
          'has_warranty': _hasWarranty ? 1 : 0,
          if (_compatController.text.trim().isNotEmpty)
            'compatibility': _compatController.text.trim(),
        },
        images: _images,
      );
      ref.invalidate(sparePartsListProvider);
      ref.invalidate(featuredPartsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Part listed successfully!'),
              backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
