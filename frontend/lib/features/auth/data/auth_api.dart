import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

class AuthApi {
  final ApiClient apiClient;

  AuthApi(this.apiClient);

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await apiClient.dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    return AuthResponse.fromJson(response.data);
  }

  Future<void> register(RegisterRequest request) async {
    await apiClient.dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );
  }

  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.dio.get(
      ApiConstants.me,
    );

    return UserModel.fromJson(response.data);
  }

  Future<void> logout() async {
    await apiClient.dio.post(
      ApiConstants.logout,
    );
  }
}