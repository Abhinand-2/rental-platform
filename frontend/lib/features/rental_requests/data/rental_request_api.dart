import '../../../core/network/api_client.dart';
import '../models/create_rental_request.dart';
import '../models/rental_request_model.dart';

class RentalRequestApi {
  final ApiClient apiClient;

  RentalRequestApi(this.apiClient);

  Future<RentalRequestModel> createRentalRequest(
    CreateRentalRequest request,
  ) async {
    final response = await apiClient.dio.post(
      '/api/rental-requests',
      data: request.toJson(),
    );

    return RentalRequestModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

Future<List<RentalRequestModel>> getOwnerRentalRequests() async {
  final response = await apiClient.dio.get(
    '/api/rental-requests/owner',
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

Future<RentalRequestModel> approveRentalRequest(
  String requestId,
) async {
  final response = await apiClient.dio.put(
    '/api/rental-requests/$requestId/approve',
  );

  return RentalRequestModel.fromJson(
    response.data as Map<String, dynamic>,
  );
}

Future<RentalRequestModel> rejectRentalRequest(
  String requestId,
) async {
  final response = await apiClient.dio.put(
    '/api/rental-requests/$requestId/reject',
  );

  return RentalRequestModel.fromJson(
    response.data as Map<String, dynamic>,
  );
}

  Future<List<RentalRequestModel>>
      getMyRentalRequests() async {
    final response = await apiClient.dio.get(
      '/api/rental-requests/my',
    );

    final List<dynamic> data =
        response.data as List<dynamic>;

    return data
        .map(
          (json) => RentalRequestModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}