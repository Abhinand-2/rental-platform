import '../../../core/network/api_client.dart';

import '../../leases/models/lease_model.dart';
import '../../properties/models/property_model.dart';
import '../../rental_requests/models/rental_request_model.dart';
import '../models/admin_user_model.dart';
import '../models/admin_dashboard_model.dart';

class AdminApi {
  final ApiClient apiClient;

  AdminApi(this.apiClient);

  Future<List<PropertyModel>> getProperties() async {
    final response = await apiClient.dio.get('/api/properties');

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => PropertyModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<PropertyModel> approveProperty(
    String propertyId,
  ) async {
    final response = await apiClient.dio.put(
      '/api/properties/$propertyId/approve',
    );

    return PropertyModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<PropertyModel> rejectProperty(
    String propertyId,
  ) async {
    final response = await apiClient.dio.put(
      '/api/properties/$propertyId/reject',
    );

    return PropertyModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<AdminUserModel>> getUsers() async {
    final response = await apiClient.dio.get(
      '/api/admin/users',
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => AdminUserModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }


  Future<AdminUserModel> updateUserStatus(
    String userId,
    String status,
  ) async {
    final response = await apiClient.dio.put(
      '/api/admin/users/$userId/status',
      data: {
        'status': status,
      },
    );

    return AdminUserModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<List<RentalRequestModel>> getRentalRequests() async {
    final response = await apiClient.dio.get(
      '/api/rental-requests/admin',
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => RentalRequestModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<LeaseModel>> getLeases() async {
    final response = await apiClient.dio.get(
      '/api/leases/admin',
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => LeaseModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
  Future<AdminDashboardModel> getDashboardStatistics() async {
  final response = await apiClient.dio.get(
    '/api/admin/dashboard',
  );

  return AdminDashboardModel.fromJson(
    response.data as Map<String, dynamic>,
  );
}
}