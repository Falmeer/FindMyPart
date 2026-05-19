import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _completePhone;
  bool _phoneValid = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (!_phoneValid || _completePhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authStateProvider.notifier).register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: 'customer',
            phone: _completePhone,
          );
      if (!mounted) return;
      final authState = ref.read(authStateProvider);
      if (authState.hasError) {
        final msg = _friendlyError(authState.error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.error),
        );
      } else {
        context.go('/');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(e)), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object? error) {
    if (error is DioException) {
      final inner = error.error;
      if (inner is AppException) return inner.message;
      if (error.message != null && error.message!.isNotEmpty) return error.message!;
    }
    if (error is AppException) return error.message;
    // Don't expose internal Dart errors to the user
    return 'Registration failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo_icon.png', width: 40, height: 40),
                    const SizedBox(width: 10),
                    Text('Join FindMyPart', style: theme.textTheme.headlineMedium),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Create an account and get started',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  initialCountryCode: _detectInitialCountry(),
                  keyboardType: TextInputType.phone,
                  onChanged: (phone) {
                    _completePhone = phone.completeNumber;
                    try {
                      _phoneValid = phone.isValidNumber();
                    } catch (_) {
                      _phoneValid = false;
                    }
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) return 'Phone number is required';
                    return null;
                  },
                  invalidNumberMessage: 'Invalid phone number',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Minimum 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Create Account',
                  onPressed: _loading ? null : _register,
                  isLoading: _loading,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.explore_outlined, size: 18),
                    label: const Text('Browse as Guest'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F7E7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 18, color: Color(0xFF128C7E)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 13, color: Color(0xFF075E54), height: 1.5),
                            children: [
                              TextSpan(
                                text: 'For Garages & Scrapyard registration, ',
                              ),
                              TextSpan(
                                text: 'please contact +973 33399330 on WhatsApp',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: ' to provide business details and verification.',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _detectInitialCountry() {
    // Try locale country code first (works on physical devices with regional locale set)
    final localeCountry =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode?.toUpperCase() ?? '';
    const knownCountries = {
      'BH', 'SA', 'AE', 'KW', 'QA', 'OM', 'JO', 'EG', 'GB', 'US', 'IN', 'PK',
    };
    if (knownCountries.contains(localeCountry)) return localeCountry;

    // Default to Bahrain — primary market for this app
    return 'BH';
  }
}

