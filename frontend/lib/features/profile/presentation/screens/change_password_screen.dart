import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final wasForced = ref.read(currentUserProvider)?.mustChangePassword ?? false;
    setState(() => _loading = true);
    try {
      await ref.read(authStateProvider.notifier).changePassword(
            currentPassword: _currentController.text,
            newPassword: _newController.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        if (wasForced) {
          context.go('/');
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isForced = ref.watch(currentUserProvider)?.mustChangePassword ?? false;
    return Scaffold(
      appBar: AppBar(
        title: Text(isForced ? 'Set Your Password' : 'Change Password'),
        automaticallyImplyLeading: !isForced,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isForced) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your account was created by the admin. Please set a new password to continue.',
                            style: TextStyle(fontSize: 13, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 8),
                TextFormField(
                  controller: _currentController,
                  obscureText: !_showCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_showCurrent ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showCurrent = !_showCurrent),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your current password' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newController,
                  obscureText: !_showNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_showNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showNew = !_showNew),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a new password';
                    if (v.length < 8) return 'Password must be at least 8 characters';
                    if (v == _currentController.text) {
                      return 'New password must differ from current';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: !_showConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showConfirm = !_showConfirm),
                    ),
                  ),
                  validator: (v) =>
                      v != _newController.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Change Password', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
