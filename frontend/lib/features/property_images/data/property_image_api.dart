import '../../../core/network/api_client.dart';
import '../models/property_image_model.dart';

class PropertyImageApi {
  final ApiClient apiClient;

  PropertyImageApi(this.apiClient);

  Future<List<PropertyImageModel>> getPropertyImages(
    String propertyId,
  ) async {
    final response = await apiClient.dio.get(
      '/api/properties/$propertyId/images',
    );

    final List<dynamic> data = response.data as List<dynamic>;

    return data
        .map(
          (json) => PropertyImageModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}