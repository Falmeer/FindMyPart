import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() => AuthNotifier());

/// Holds the OTP code returned by the backend in dev mode (no Twilio configured).
/// Cleared after the user successfully verifies.
final devOtpCodeProvider = StateProvider<String?>((ref) => null);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    return ref.read(authRepositoryProvider).getStoredUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            password: password,
            role: role,
            phone: phone,
          ),
    );
    if (result.value?.devCode != null) {
      ref.read(devOtpCodeProvider.notifier).state = result.value!.devCode;
    }
    state = result.whenData((r) => r.user);
  }

  Future<void> updateProfile({required String name, String? phone}) async {
    final updated = await ref.read(authRepositoryProvider).updateProfile(
          name: name,
          phone: phone,
        );
    state = AsyncData(updated.copyWith(token: state.value?.token));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ref.read(authRepositoryProvider).changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
  }

  Future<void> sendOtp({String? newPhone}) async {
    final devCode = await ref.read(authRepositoryProvider).sendOtp(newPhone: newPhone);
    if (newPhone != null) {
      final current = state.value;
      if (current != null) {
        state = AsyncData(current.copyWith(phone: newPhone, phoneVerified: false));
      }
    }
    if (devCode != null) {
      ref.read(devOtpCodeProvider.notifier).state = devCode;
    }
  }

  Future<void> verifyOtp(String code) async {
    final verified = await ref.read(authRepositoryProvider).verifyOtp(code);
    ref.read(devOtpCodeProvider.notifier).state = null;
    state = AsyncData(verified);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).value;
});
