import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/property_image_api.dart';
import '../data/property_image_repository.dart';
import '../models/property_image_model.dart';

final propertyImageApiProvider =
    Provider<PropertyImageApi>((ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);

  return PropertyImageApi(apiClient);
});

final propertyImageRepositoryProvider =
    Provider<PropertyImageRepository>((ref) {
  final api = ref.read(propertyImageApiProvider);

  return PropertyImageRepository(api);
});

final propertyImagesProvider =
    FutureProvider.family<List<PropertyImageModel>, String>(
  (ref, propertyId) async {
    final repository =
        ref.read(propertyImageRepositoryProvider);

    return await repository.getPropertyImages(propertyId);
  },
);