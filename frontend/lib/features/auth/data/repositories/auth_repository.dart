import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  Future<UserModel> login(String phone, String password) async {
    final response = await _client.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    final data = response.data['data'];
    final user = UserModel.fromJson({...data['user'], 'token': data['token']});
    await _persistSession(user);
    return user;
  }

  Future<({UserModel user, String? devCode})> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final response = await _client.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'role': role,
      if (phone != null) 'phone': phone,
    });
    final data = response.data['data'];
    final user = UserModel.fromJson({...data['user'], 'token': data['token']});
    await _persistSession(user);
    return (user: user, devCode: data['dev_code'] as String?);
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } catch (_) {}
    await _clearSession();
  }

  Future<UserModel> updateProfile({required String name, String? phone}) async {
    final response = await _client.put('/auth/profile', data: {
      'name': name,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.tokenKey);
    await _persistSession(UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      avatar: user.avatar,
      token: stored,
    ));
    return user;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.put('/auth/password', data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPassword,
    });
  }

  Future<void> forgotPassword(String email) async {
    await _client.post('/auth/forgot-password', data: {'email': email});
  }

  Future<String?> sendOtp({String? newPhone}) async {
    final response = await _client.post('/auth/phone/send-otp', data: {
      if (newPhone != null) 'phone': newPhone,
    });
    // Only present in dev when Twilio is not configured
    return response.data['dev_code'] as String?;
  }

  Future<UserModel> verifyOtp(String code) async {
    final response = await _client.post('/auth/phone/verify', data: {'code': code});
    final user = UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(AppConstants.tokenKey);
    final updated = user.copyWith(token: stored);
    await _persistSession(updated);
    return updated;
  }

  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    final userJson = prefs.getString(AppConstants.userKey);
    if (token == null || userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> _persistSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, user.token ?? '');
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}
