import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> loginWithEmail(String email, String password);
  Future<UserEntity> registerWithEmail(String email, String password, String? name);
  Future<UserEntity> loginWithGoogle();
  Future<UserEntity> loginWithApple();
  Future<UserEntity> loginWithOtp(String phone);
  Future<UserEntity> verifyOtp(String phone, String code);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<String?> getToken();
  Stream<UserEntity?> authStateChanges();
}
