import '../../leases/models/lease_model.dart';
import '../../properties/models/property_model.dart';
import '../../rental_requests/models/rental_request_model.dart';
import '../models/admin_user_model.dart';
import 'admin_api.dart';
import '../models/admin_dashboard_model.dart';

class AdminRepository {
  final AdminApi api;

  AdminRepository(this.api);

  Future<List<PropertyModel>> getProperties() {
    return api.getProperties();
  }

  Future<PropertyModel> approveProperty(
    String propertyId,
  ) {
    return api.approveProperty(propertyId);
  }

  Future<PropertyModel> rejectProperty(
    String propertyId,
  ) {
    return api.rejectProperty(propertyId);
  }

  Future<List<AdminUserModel>> getUsers() {
    return api.getUsers();
  }

  Future<AdminUserModel> updateUserStatus(String userId, String status) {
    return api.updateUserStatus(userId, status);
  }

  Future<List<RentalRequestModel>> getRentalRequests() {
    return api.getRentalRequests();
  }

  Future<List<LeaseModel>> getLeases() {
    return api.getLeases();
  }
  Future<AdminDashboardModel> getDashboardStatistics() {
  return api.getDashboardStatistics();
}
}