
import '../../../core/network/api_client.dart';
import '../models/property_model.dart';
import '../models/create_property_request.dart';
import '../models/update_property_request.dart';

class PropertyApi {
  final ApiClient apiClient;

  PropertyApi(this.apiClient);

  Future<PropertyModel> getPropertyById(String propertyId) async {
  final response = await apiClient.dio.get(
    '/api/properties/$propertyId',
  );

  return PropertyModel.fromJson(
    response.data as Map<String, dynamic>,
  );
}

Future<PropertyModel> updateProperty(
  String propertyId,
  UpdatePropertyRequest request,
) async {
  final response = await apiClient.dio.put(
    '/api/properties/$propertyId',
    data: request.toJson(),
  );

  return PropertyModel.fromJson(
    response.data as Map<String, dynamic>,
  );
}

Future<PropertyModel> publishProperty(String propertyId) async {
  final response = await apiClient.dio.put(
    '/api/properties/$propertyId/publish',
  );

  return PropertyModel.fromJson(
    response.data as Map<String, dynamic>,
  );
}

Future<PropertyModel> createProperty(
  CreatePropertyRequest request,
) async {
  final response = await apiClient.dio.post(
    '/api/properties',
    data: request.toJson(),
  );

  return PropertyModel.fromJson(
    response.data as Map<String, dynamic>,
  );
}

Future<List<PropertyModel>> getOwnerProperties(
  String ownerId,
) async {
  final response = await apiClient.dio.get(
    '/api/properties/owner/$ownerId',
  );

  final List<dynamic> data =
      response.data as List<dynamic>;

  return data
      .map(
        (json) => PropertyModel.fromJson(
          json as Map<String, dynamic>,
        ),
      )
      .toList();
}


  Future<List<PropertyModel>> getPublishedProperties() async {
    final response = await apiClient.dio.get(
      '/api/properties/published',
    );

    final List<dynamic> data = response.data as List<dynamic>;

    return data
        .map(
          (json) => PropertyModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}