import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';

import '../../../core/network/api_client.dart';
import '../data/lease_api.dart';
import '../data/lease_repository.dart';
import '../models/lease_model.dart';

final leaseApiProvider = Provider<LeaseApi>((ref) {
  return LeaseApi(
    ref.read(apiClientProvider),
  );
});

final leaseRepositoryProvider =
    Provider<LeaseRepository>((ref) {
  return LeaseRepository(
    ref.read(leaseApiProvider),
  );
});

final ownerLeasesProvider =
    FutureProvider<List<LeaseModel>>((ref) async {
  final repository =
      ref.read(leaseRepositoryProvider);

  return repository.getOwnerLeases();
});

final leaseDetailsProvider =
    FutureProvider.family<LeaseModel, String>(
  (ref, leaseId) async {
    final repository =
        ref.read(leaseRepositoryProvider);

    return repository.getLease(leaseId);
  },
);