import '../models/property_image_model.dart';
import 'property_image_api.dart';

class PropertyImageRepository {
  final PropertyImageApi propertyImageApi;

  PropertyImageRepository(this.propertyImageApi);

  Future<List<PropertyImageModel>> getPropertyImages(
    String propertyId,
  ) async {
    return await propertyImageApi.getPropertyImages(propertyId);
  }
}