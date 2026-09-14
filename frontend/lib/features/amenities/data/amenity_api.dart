import '../../../core/network/api_client.dart';
import '../models/amenity_model.dart';

class AmenityApi {
  final ApiClient apiClient;

  AmenityApi(this.apiClient);

  Future<List<AmenityModel>> getPropertyAmenities(
    String propertyId,
  ) async {
    final response = await apiClient.dio.get(
      '/api/properties/$propertyId/amenities',
    );

    final List<dynamic> data = response.data as List<dynamic>;

    return data
        .map(
          (json) => AmenityModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}