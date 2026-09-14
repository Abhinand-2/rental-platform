import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/rent_api.dart';
import '../data/rent_repository.dart';
import '../models/rent_charge_model.dart';

final rentApiProvider = Provider<RentApi>((ref) {
  final apiClient = ref.read(apiClientProvider);

  return RentApi(apiClient);
});

final rentRepositoryProvider = Provider<RentRepository>((ref) {
  final api = ref.read(rentApiProvider);

  return RentRepository(api);
});

final ownerRentChargesProvider =
    FutureProvider<List<RentChargeModel>>((ref) async {
  final repository = ref.read(rentRepositoryProvider);

  return repository.getOwnerRentCharges();
});