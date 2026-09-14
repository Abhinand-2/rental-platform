import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/amenity_api.dart';
import '../data/amenity_repository.dart';
import '../models/amenity_model.dart';

final amenityApiProvider = Provider<AmenityApi>((ref) {
  final apiClient = ref.read(apiClientProvider);

  return AmenityApi(apiClient);
});

final amenityRepositoryProvider =
    Provider<AmenityRepository>((ref) {
  final api = ref.read(amenityApiProvider);

  return AmenityRepository(api);
});

final propertyAmenitiesProvider =
    FutureProvider.family<List<AmenityModel>, String>(
  (ref, propertyId) async {
    final repository =
        ref.read(amenityRepositoryProvider);

    return await repository.getPropertyAmenities(propertyId);
  },
);