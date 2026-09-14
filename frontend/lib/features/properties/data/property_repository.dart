import 'package:frontend/features/properties/models/update_property_request.dart';

import '../models/property_model.dart';
import 'property_api.dart';
import '../models/create_property_request.dart';

class PropertyRepository {
  final PropertyApi propertyApi;

  PropertyRepository(this.propertyApi);

  Future<List<PropertyModel>> getPublishedProperties() async {
    return await propertyApi.getPublishedProperties();
  }
Future<List<PropertyModel>> getOwnerProperties(
  String ownerId,
) async {
  return await propertyApi.getOwnerProperties(ownerId);
}

Future<PropertyModel> publishProperty(String propertyId) {
  return propertyApi.publishProperty(propertyId);
}

Future<PropertyModel> updateProperty(
  String propertyId,
  UpdatePropertyRequest request,
) async {
  return await propertyApi.updateProperty(
    propertyId,
    request,
  );
}

Future<PropertyModel> createProperty(
  CreatePropertyRequest request,
) async {
  return await propertyApi.createProperty(request);
}

  Future<PropertyModel> getPropertyById(String propertyId) async {
    return await propertyApi.getPropertyById(propertyId);
  }
}