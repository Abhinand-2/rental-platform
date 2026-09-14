import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/property_api.dart';
import '../data/property_repository.dart';
import '../models/property_model.dart';

final propertyApiProvider = Provider<PropertyApi>((ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);

  return PropertyApi(apiClient);
});

final ownerPropertiesProvider =
    FutureProvider.family<List<PropertyModel>, String>(
  (ref, ownerId) async {
    final repository =
        ref.read(propertyRepositoryProvider);

    return await repository.getOwnerProperties(ownerId);
  },
);

final propertyRepositoryProvider =
    Provider<PropertyRepository>((ref) {
  final propertyApi = ref.read(propertyApiProvider);

  return PropertyRepository(propertyApi);
});

final publishedPropertiesProvider =
    FutureProvider<List<PropertyModel>>((ref) async {
  final repository = ref.read(propertyRepositoryProvider);

  return await repository.getPublishedProperties();
});

final propertyDetailsProvider =
    FutureProvider.family<PropertyModel, String>(
  (ref, propertyId) async {
    final repository =
        ref.read(propertyRepositoryProvider);

    return await repository.getPropertyById(propertyId);
  },
);