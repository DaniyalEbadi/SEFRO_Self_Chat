import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/di/service_locator.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserEntity? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase = ServiceLocator().get<LoginUseCase>();
  final RegisterUseCase _registerUseCase = ServiceLocator()
      .get<RegisterUseCase>();
  final AuthRepository _authRepository = ServiceLocator().get<AuthRepository>();

  AuthNotifier() : super(const AuthState());

  Future<void> loginWithEmail(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _loginUseCase(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> register(String email, String password, String? name) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _registerUseCase(email, password, name);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.loginWithGoogle();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> loginWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.loginWithApple();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> loginWithOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.loginWithOtp(phone);
      state = const AuthState(status: AuthStatus.initial);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> verifyOtp(String phone, String code) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _authRepository.verifyOtp(phone, code);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null, status: AuthStatus.unauthenticated);
  }
}
