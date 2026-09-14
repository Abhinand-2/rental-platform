import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/rental_request_api.dart';
import '../data/rental_request_repository.dart';
import '../models/create_rental_request.dart';
import '../models/rental_request_model.dart';

final rentalRequestApiProvider =
    Provider<RentalRequestApi>((ref) {
  final apiClient = ref.read(apiClientProvider);

  return RentalRequestApi(apiClient);
});

final rentalRequestRepositoryProvider =
    Provider<RentalRequestRepository>((ref) {
  final api = ref.read(rentalRequestApiProvider);

  return RentalRequestRepository(api);
});

final myRentalRequestsProvider =
    FutureProvider<List<RentalRequestModel>>((ref) async {
  final repository =
      ref.read(rentalRequestRepositoryProvider);

  return await repository.getMyRentalRequests();
});

class RentalRequestNotifier
    extends StateNotifier<AsyncValue<RentalRequestModel?>> {
  final RentalRequestRepository repository;

  RentalRequestNotifier(this.repository)
      : super(const AsyncData(null));

  Future<void> create(
    CreateRentalRequest request,
  ) async {
    state = const AsyncLoading();

    try {
      final result =
          await repository.createRentalRequest(request);

      state = AsyncData(result);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final rentalRequestNotifierProvider =
    StateNotifierProvider<RentalRequestNotifier,
        AsyncValue<RentalRequestModel?>>((ref) {
  return RentalRequestNotifier(
    ref.read(rentalRequestRepositoryProvider),
  );
});

final ownerRentalRequestsProvider =
    FutureProvider<List<RentalRequestModel>>((ref) async {
  final repository =
      ref.read(rentalRequestRepositoryProvider);

  return repository.getOwnerRentalRequests();
});