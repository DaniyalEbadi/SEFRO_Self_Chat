import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;
  final _uuid = const Uuid();
  static const _sessionKey = 'current_user_profile';
  static const _otpCodeKey = 'pending_otp_code';
  static const _otpPhoneKey = 'pending_otp_phone';

  AuthRepositoryImpl(this._supabase, this._local);

  Future<void> _saveUser(UserEntity user) async {
    final payload = jsonEncode(_toJson(user));
    await _local.setSecure(_sessionKey, payload);
    await _local.saveToken(user.id);
    await _local.setString(AppConstants.prefUserId, user.id);
  }

  UserEntity _fromJson(Map<String, dynamic> data) {
    return UserEntity(
      id: data['id'] as String? ?? '',
      email: data['email'] as String?,
      phone: data['phone'] as String?,
      name: data['name'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'] as String)
          : null,
      lastLoginAt: data['last_login_at'] != null
          ? DateTime.tryParse(data['last_login_at'] as String)
          : null,
      isPremium: data['is_premium'] as bool? ?? false,
      preferences: data['preferences'] as Map<String, dynamic>? ?? const {},
    );
  }

  Map<String, dynamic> _toJson(UserEntity user) => {
    'id': user.id,
    'email': user.email,
    'phone': user.phone,
    'name': user.name,
    'avatar_url': user.avatarUrl,
    'created_at': user.createdAt?.toIso8601String(),
    'last_login_at': user.lastLoginAt?.toIso8601String(),
    'is_premium': user.isPremium,
    'preferences': user.preferences,
  };

  Future<UserEntity> _currentSessionUser() async {
    final raw = await _local.getSecure(_sessionKey);
    if (raw == null || raw.isEmpty) {
      throw Exception('کاربر وارد نشده است');
    }
    return _fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<UserEntity> loginWithEmail(String email, String password) async {
    final user = UserEntity(
      id: _uuid.v4(),
      email: email,
      name: email.split('@').first,
      lastLoginAt: DateTime.now(),
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<UserEntity> registerWithEmail(
    String email,
    String password,
    String? name,
  ) async {
    final user = UserEntity(
      id: _uuid.v4(),
      email: email,
      name: name ?? email.split('@').first,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    final user = UserEntity(
      id: _uuid.v4(),
      email: 'google.user@example.com',
      name: 'Google User',
      avatarUrl: null,
      lastLoginAt: DateTime.now(),
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<UserEntity> loginWithApple() async {
    final user = UserEntity(
      id: _uuid.v4(),
      email: 'apple.user@example.com',
      name: 'Apple User',
      avatarUrl: null,
      lastLoginAt: DateTime.now(),
    );
    await _saveUser(user);
    return user;
  }

  @override
  Future<UserEntity> loginWithOtp(String phone) async {
    final otpCode = '123456';
    await _local.setSecure(_otpCodeKey, otpCode);
    await _local.setSecure(_otpPhoneKey, phone);
    return UserEntity(id: 'pending-otp', phone: phone, name: 'کاربر پیامکی');
  }

  @override
  Future<UserEntity> verifyOtp(String phone, String code) async {
    final storedCode = await _local.getSecure(_otpCodeKey);
    final storedPhone = await _local.getSecure(_otpPhoneKey);
    final isValid = storedCode == code && storedPhone == phone;

    if (!isValid) {
      throw Exception('کد تأیید اشتباه است');
    }

    final user = UserEntity(
      id: _uuid.v4(),
      phone: phone,
      name: 'کاربر پیامکی',
      lastLoginAt: DateTime.now(),
    );
    await _saveUser(user);
    await _local.removeSecure(_otpCodeKey);
    await _local.removeSecure(_otpPhoneKey);
    return user;
  }

  @override
  Future<void> logout() async {
    await _supabase.authSignOut();
    await _local.clearToken();
    await _local.removeSecure(_sessionKey);
    await _local.remove(AppConstants.prefUserId);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      return await _currentSessionUser();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _local.getToken();
    return token != null;
  }

  @override
  Future<String?> getToken() => _local.getToken();

  @override
  Stream<UserEntity?> authStateChanges() {
    return Stream.periodic(
      const Duration(seconds: 30),
      (_) => null,
    ).asyncMap((_) => getCurrentUser());
  }
}
