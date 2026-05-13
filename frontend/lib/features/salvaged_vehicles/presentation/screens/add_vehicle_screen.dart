import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/car_api_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/image_picker_grid.dart';
import '../../data/repositories/vehicles_repository.dart';
import '../../providers/vehicles_provider.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _engineController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _vinController = TextEditingController();

  String? _brand;
  String? _model;
  int? _year;
  String _transmission = 'Automatic';
  String _condition = 'Used';
  bool _isLoading = false;
  List<PickedImage> _images = [];

  static final _years = List.generate(2027 - 1930 + 1, (i) => 2027 - i);

  @override
  void dispose() {
    _engineController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final makes = ref.watch(carMakesProvider);
    final modelsAsync = _brand != null ? ref.watch(carModelsProvider(_brand!)) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('List a Vehicle')),
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
                Text('Vehicle Details', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),

                // Brand autocomplete
                const Text('Brand *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Autocomplete<String>(
                  initialValue: TextEditingValue(text: _brand ?? ''),
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) return makes;
                    final q = textEditingValue.text.toLowerCase();
                    return makes.where((m) => m.toLowerCase().contains(q));
                  },
                  onSelected: (value) => setState(() {
                    _brand = value;
                    _model = null;
                  }),
                  fieldViewBuilder: (_, controller, focusNode, __) => TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (v) {
                      if (v.isEmpty) setState(() { _brand = null; _model = null; });
                    },
                    decoration: InputDecoration(
                      hintText: 'Type to search brand...',
                      prefixIcon: _brand != null
                          ? Padding(
                              padding: const EdgeInsets.all(10),
                              child: BrandLogo(brand: _brand!, size: 22),
                            )
                          : const Icon(Icons.directions_car_outlined, size: 18),
                    ),
                  ),
                  optionsViewBuilder: (context, onSelected, options) => Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220, maxWidth: 320),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (_, i) {
                            final option = options.elementAt(i);
                            return ListTile(
                              dense: true,
                              leading: BrandLogo(brand: option, size: 28),
                              title: Text(option, style: const TextStyle(fontSize: 13)),
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Model dropdown
                const Text('Model *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                if (_brand == null)
                  const _DisabledField(hint: 'Select a brand first')
                else if (modelsAsync != null)
                  modelsAsync.when(
                    data: (models) => models.isEmpty
                        ? const _DisabledField(hint: 'No models found — type manually')
                        : _StyledDropdown<String>(
                            value: _model,
                            hint: 'Select model',
                            items: models,
                            labelOf: (v) => v ?? '',
                            onChanged: (v) => setState(() => _model = v),
                          ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const _DisabledField(hint: 'Could not load models'),
                  ),

                const SizedBox(height: 14),

                // Year + Mileage row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Year *',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          _StyledDropdown<int>(
                            value: _year,
                            hint: 'Select year',
                            items: _years,
                            labelOf: (v) => v != null ? '$v' : '',
                            onChanged: (v) => setState(() => _year = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Mileage (km)',
                        controller: _mileageController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                AppTextField(
                  label: 'Engine (e.g. 2.0L 4-cyl)',
                  controller: _engineController,
                ),
                const SizedBox(height: 14),
                _buildDropdown('Transmission', ['Automatic', 'Manual'], _transmission,
                    (v) => setState(() => _transmission = v!)),
                const SizedBox(height: 14),
                _buildDropdown('Condition', ['Used', 'Damaged', 'Parts Only'], _condition,
                    (v) => setState(() => _condition = v!)),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'VIN (Optional)',
                  controller: _vinController,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Price (BHD) — leave blank to negotiate',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Description',
                  controller: _descController,
                  maxLines: 4,
                  validator: (v) => v?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Post Vehicle',
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

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _submit() async {
    if (_brand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a brand'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a model'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (_year == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a year'), backgroundColor: AppColors.error),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(vehiclesRepositoryProvider).createVehicle(
        fields: {
          'brand': _brand!,
          'model': _model!,
          'year': _year!,
          'condition': _condition,
          'transmission': _transmission,
          if (_engineController.text.trim().isNotEmpty)
            'engine': _engineController.text.trim(),
          if (_mileageController.text.trim().isNotEmpty)
            'mileage': int.tryParse(_mileageController.text.trim()),
          if (_priceController.text.trim().isNotEmpty)
            'price': double.tryParse(_priceController.text.trim()),
          if (_vinController.text.trim().isNotEmpty)
            'vin': _vinController.text.trim(),
          'description': _descController.text.trim(),
        },
        images: _images,
      );
      ref.invalidate(vehiclesListProvider);
      ref.invalidate(featuredVehiclesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Vehicle listed successfully!'),
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

class _DisabledField extends StatelessWidget {
  final String hint;
  const _DisabledField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surfaceVariant,
      ),
      child: Text(hint,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final String Function(T?) labelOf;
  final void Function(T?) onChanged;

  const _StyledDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        hint: Text(hint,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 13)),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(labelOf(item), overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
