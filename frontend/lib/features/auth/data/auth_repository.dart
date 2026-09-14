import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi authApi;

  AuthRepository(this.authApi);

  Future<AuthResponse> login(LoginRequest request) async {
    return await authApi.login(request);
  }

  Future<void> register(RegisterRequest request) async {
    await authApi.register(request);
  }

  Future<UserModel> getCurrentUser() async {
    return await authApi.getCurrentUser();
  }

  Future<void> logout() async {
    await authApi.logout();
  }
}