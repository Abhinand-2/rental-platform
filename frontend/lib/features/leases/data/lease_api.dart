import '../../../core/network/api_client.dart';
import '../models/lease_model.dart';

class LeaseApi {
  final ApiClient apiClient;

  LeaseApi(this.apiClient);

  Future<List<LeaseModel>> getOwnerLeases() async {
    final response = await apiClient.dio.get(
      '/api/leases/owner',
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

  Future<LeaseModel> getLease(
    String leaseId,
  ) async {
    final response = await apiClient.dio.get(
      '/api/leases/$leaseId',
    );

    return LeaseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<LeaseModel> createLease({
    required String rentalRequestId,
    required String startDate,
    required String endDate,
    required double monthlyRent,
    double? securityDeposit,
  }) async {
    final response = await apiClient.dio.post(
      '/api/leases',
      data: {
        'rentalRequestId': rentalRequestId,
        'startDate': startDate,
        'endDate': endDate,
        'monthlyRent': monthlyRent,
        'securityDeposit': securityDeposit,
      },
    );

    return LeaseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<LeaseModel> terminateLease(
    String leaseId,
  ) async {
    final response = await apiClient.dio.put(
      '/api/leases/$leaseId/terminate',
    );

    return LeaseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<LeaseModel> cancelLease(
    String leaseId,
  ) async {
    final response = await apiClient.dio.put(
      '/api/leases/$leaseId/cancel',
    );

    return LeaseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}