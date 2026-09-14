import '../models/amenity_model.dart';
import 'amenity_api.dart';

class AmenityRepository {
  final AmenityApi amenityApi;

  AmenityRepository(this.amenityApi);

  Future<List<AmenityModel>> getPropertyAmenities(
    String propertyId,
  ) async {
    return await amenityApi.getPropertyAmenities(propertyId);
  }
}