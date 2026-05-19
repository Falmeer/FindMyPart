import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PhoneVerificationScreen extends ConsumerStatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  ConsumerState<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends ConsumerState<PhoneVerificationScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  bool _verifying = false;
  bool _sending = false;
  int _resendCountdown = 60;
  Timer? _timer;
  String? _devCode;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
      final code = ref.read(devOtpCodeProvider);
      if (code != null) {
        setState(() => _devCode = code);
      } else {
        // No code in memory — user returned to app before verifying, or coming
        // from a login that didn't auto-send (e.g. restored session).
        // Backend rate-limits to once per 60 s, so this is safe to call silently.
        _sendInitialOtp();
      }
    });
  }

  Future<void> _sendInitialOtp() async {
    try {
      await ref.read(authStateProvider.notifier).sendOtp();
      final devCode = ref.read(devOtpCodeProvider);
      if (mounted && devCode != null) setState(() => _devCode = devCode);
    } catch (_) {
      // 429 (rate-limited) or Twilio error — a code was already sent recently,
      // so we just leave the screen open and let the user hit Resend when ready.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) { c.dispose(); }
    for (final f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length != 6 || _verifying) return;
    setState(() => _verifying = true);
    try {
      await ref.read(authStateProvider.notifier).verifyOtp(_code);
      // Router will redirect automatically once phoneVerified becomes true
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
        // Clear fields on wrong code
        for (final c in _controllers) { c.clear(); }
        _focusNodes[0].requestFocus();
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resendCountdown > 0 || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(authStateProvider.notifier).sendOtp();
      _startCountdown();
      final devCode = ref.read(devOtpCodeProvider);
      if (mounted) {
        setState(() => _devCode = devCode);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New code sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verify();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final phone = user?.phone ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Verify Phone'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sms_outlined, size: 38, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'Enter verification code',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit code to\n$phone',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
              if (_devCode != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.developer_mode, size: 16, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Text(
                        'Dev code: $_devCode',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 2,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final isActive = _focusNodes[i].hasFocus;
                  final hasValue = _controllers[i].text.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 46,
                      height: 56,
                      decoration: BoxDecoration(
                        color: hasValue ? AppColors.primaryLight : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : hasValue
                                  ? AppColors.primary.withValues(alpha: 0.4)
                                  : AppColors.border,
                          width: isActive ? 2 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) => _onDigitChanged(i, v),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_code.length == 6 && !_verifying) ? _verify : null,
                  child: _verifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verify'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive it? ",
                      style: TextStyle(color: AppColors.textSecondary)),
                  _resendCountdown > 0
                      ? Text(
                          'Resend in ${_resendCountdown}s',
                          style: const TextStyle(color: AppColors.textTertiary),
                        )
                      : GestureDetector(
                          onTap: _sending ? null : _resend,
                          child: Text(
                            _sending ? 'Sending...' : 'Resend code',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
