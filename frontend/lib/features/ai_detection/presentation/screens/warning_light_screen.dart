import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/warning_light_result.dart';
import '../../data/repositories/ai_repository.dart';

class WarningLightScreen extends ConsumerStatefulWidget {
  const WarningLightScreen({super.key});

  @override
  ConsumerState<WarningLightScreen> createState() => _WarningLightScreenState();
}

class _WarningLightScreenState extends ConsumerState<WarningLightScreen> {
  Uint8List? _imageBytes;
  String? _imageName;
  bool _analyzing = false;
  WarningLightResult? _result;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1280,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageName = picked.name;
      _result = null;
      _error = null;
    });
    _analyze();
  }

  Future<void> _analyze() async {
    if (_imageBytes == null) return;
    setState(() {
      _analyzing = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await ref
          .read(aiRepositoryProvider)
          .analyzeWarningLight(_imageBytes!, _imageName ?? 'image.jpg');
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('429') || e.toString().contains('Too many')
            ? 'Too many requests. Please wait a moment and try again.'
            : 'Analysis failed. Please try again.';
        setState(() => _error = msg);
      }
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warning Light Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImageArea(),
            const SizedBox(height: 20),
            _buildPickerButtons(),
            const SizedBox(height: 24),
            if (_analyzing) _buildAnalyzingCard(),
            if (_error != null) _buildErrorCard(_error!),
            if (_result != null) _buildResultSection(_result!),
            if (!_analyzing && _result == null && _error == null)
              _buildHintCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    return GestureDetector(
      onTap: () => _showSourceDialog(),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _imageBytes != null ? AppColors.primary : AppColors.border,
            width: _imageBytes != null ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _imageBytes != null
            ? Image.memory(_imageBytes!, fit: BoxFit.cover)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        size: 36, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tap to take or upload a photo',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Point camera at dashboard warning lights',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPickerButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Camera'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Gallery'),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analyzing warning lights...',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.primary)),
                SizedBox(height: 2),
                Text('AI is identifying all visible symbols',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: AppColors.error, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(WarningLightResult result) {
    if (!result.identified) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.help_outline, size: 36, color: AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Could not identify',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(result.message ?? 'Please try a clearer image.',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.lights.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '${result.lights.length} warning lights detected',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary),
            ),
          ),
        ...result.lights.asMap().entries.map((entry) {
          final i = entry.key;
          final light = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: i < result.lights.length - 1 ? 16 : 0),
            child: _buildLightCard(light),
          );
        }),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showSourceDialog(),
          icon: const Icon(Icons.refresh),
          label: const Text('Scan Another'),
        ),
      ],
    );
  }

  Widget _buildLightCard(WarningLightItem light) {
    final (color, bgColor, icon, label) = _severityStyle(light.severity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                '$label SEVERITY',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(light.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 16),
              _InfoSection(
                icon: Icons.info_outline,
                title: 'What it means',
                content: light.explanation,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: 14),
              _InfoSection(
                icon: Icons.build_outlined,
                title: 'Recommended Action',
                content: light.action,
                iconColor: AppColors.success,
              ),
              if (light.severity == 'high') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.error, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Do not ignore this warning. Stop driving if safe to do so.',
                          style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tips for best results',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          ...[
            'You can scan multiple warning lights at once',
            'Make sure all lights are clearly visible',
            'Good lighting helps with accuracy',
            'Avoid blurry or dark images',
          ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(tip,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  (Color, Color, IconData, String) _severityStyle(String severity) {
    return switch (severity) {
      'high'   => (AppColors.error, AppColors.errorLight, Icons.warning_rounded, 'HIGH'),
      'medium' => (AppColors.warning, AppColors.warningLight, Icons.info_rounded, 'MEDIUM'),
      _        => (AppColors.success, AppColors.successLight, Icons.check_circle_rounded, 'LOW'),
    };
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color iconColor;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 3),
              Text(content,
                  style: const TextStyle(fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
