import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/car_api_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../data/repositories/garages_repository.dart';

class PostIssueScreen extends ConsumerStatefulWidget {
  const PostIssueScreen({super.key});

  @override
  ConsumerState<PostIssueScreen> createState() => _PostIssueScreenState();
}

class _PostIssueScreenState extends ConsumerState<PostIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();

  String? _brand;
  String? _model;
  int? _year;
  bool _isLoading = false;

  static final _years = List.generate(2027 - 1930 + 1, (i) => 2027 - i);

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final makes = ref.watch(carMakesProvider);
    final modelsAsync = _brand != null ? ref.watch(carModelsProvider(_brand!)) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Post a Car Issue')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Describe your car issue and nearby garages will respond with offers.',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text('Vehicle Info', style: theme.textTheme.titleMedium),
                const SizedBox(height: 14),

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
                  onSelected: (value) {
                    setState(() {
                      _brand = value;
                      _model = null;
                    });
                  },
                  fieldViewBuilder: (_, controller, focusNode, __) => TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (v) {
                      if (v.isEmpty) {
                        setState(() {
                          _brand = null;
                          _model = null;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Type to search brand...',
                      prefixIcon: Icon(Icons.directions_car_outlined, size: 18),
                    ),
                  ),
                  optionsViewBuilder: (context, onSelected, options) => Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: 220, maxWidth: 320),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (_, i) {
                            final option = options.elementAt(i);
                            return ListTile(
                              dense: true,
                              leading: BrandLogo(brand: option, size: 28),
                              title: Text(option,
                                  style: const TextStyle(fontSize: 13)),
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

                // Year dropdown
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

                const SizedBox(height: 24),
                Text('Issue Description', style: theme.textTheme.titleMedium),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Describe the problem in detail...',
                  controller: _issueController,
                  maxLines: 5,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (v.length < 20) {
                      return 'Please provide more details (min 20 chars)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: AppColors.textTertiary),
                        SizedBox(height: 4),
                        Text('Add photos (optional)',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AppButton(
                    label: 'Post Issue', onPressed: _submit, isLoading: _isLoading),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_brand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a brand'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    if (_model == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a model'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    if (_year == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a year'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(garagesRepositoryProvider).postIssue({
        'brand': _brand!,
        'model': _model!,
        'year': _year!,
        'description': _issueController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Issue posted! Garages will respond soon.'),
            backgroundColor: AppColors.success,
          ),
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
