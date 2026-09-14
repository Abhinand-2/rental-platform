import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import '../models/login_request.dart';
import '../models/user_model.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  return ApiClient(tokenStorage);
});

final authApiProvider = Provider<AuthApi>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthApi(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final authApi = ref.read(authApiProvider);
  return AuthRepository(authApi);
});

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final String? accessToken;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.accessToken,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? accessToken,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      accessToken: accessToken ?? this.accessToken,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final TokenStorage tokenStorage;

  AuthNotifier(
    this.repository,
    this.tokenStorage,
  ) : super(const AuthState());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      // 1. Login
      final response = await repository.login(
        LoginRequest(
          email: email,
          password: password,
        ),
      );

      // 2. Store JWT tokens
      await tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // 3. Ask backend who the logged-in user is
      final user = await repository.getCurrentUser();

      // 4. Store authentication + user information
      state = AuthState(
        isLoading: false,
        isLoggedIn: true,
        accessToken: response.accessToken,
        user: user,
      );
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

      await tokenStorage.clear();

      state = AuthState(
        isLoading: false,
        isLoggedIn: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await repository.logout();
    } catch (_) {
      // Local logout should still happen
      // even if backend logout fails.
    }

    await tokenStorage.clear();

    state = const AuthState();
  }
    Future<void> restoreSession() async {
  final accessToken = await tokenStorage.getAccessToken();

  if (accessToken == null || accessToken.isEmpty) {
    state = const AuthState();
    return;
  }

  state = state.copyWith(
    isLoading: true,
    errorMessage: null,
  );

  try {
    final user = await repository.getCurrentUser();

    state = AuthState(
      isLoading: false,
      isLoggedIn: true,
      accessToken: accessToken,
      user: user,
    );
  } catch (e) {
    debugPrint('SESSION RESTORE ERROR: $e');

    await tokenStorage.clear();

    state = const AuthState();
  }
}
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(tokenStorageProvider),
  );
});