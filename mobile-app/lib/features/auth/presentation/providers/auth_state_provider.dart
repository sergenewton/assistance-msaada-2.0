import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/login_user.dart';
import '../providers/auth_providers.dart';

// État d'authentification
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Notifier pour gérer l'état d'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUser _loginUser;

  AuthNotifier(this._loginUser) : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginUser(LoginUserParams(
      email: email,
      password: password,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure is AuthenticationFailure 
            ? failure.message 
            : 'Une erreur est survenue',
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      ),
    );
  }

  void logout() {
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider pour l'état d'authentification
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    final loginUser = ref.watch(loginUserProvider);
    return AuthNotifier(loginUser);
  },
);