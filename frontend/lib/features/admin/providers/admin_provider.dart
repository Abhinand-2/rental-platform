import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';


import '../../leases/models/lease_model.dart';
import '../../properties/models/property_model.dart';
import '../../rental_requests/models/rental_request_model.dart';

import '../data/admin_api.dart';
import '../data/admin_repository.dart';
import '../models/admin_user_model.dart';

import '../data/admin_rent_api.dart';
import '../data/admin_rent_repository.dart';
import '../models/admin_rent_charge_model.dart';
import '../models/admin_dashboard_model.dart';

final adminApiProvider = Provider<AdminApi>((ref) {
  return AdminApi(
    ref.read(apiClientProvider),
  );
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(
    ref.read(adminApiProvider),
  );
});

final adminPropertiesProvider =
    FutureProvider<List<PropertyModel>>((ref) async {
  final repository = ref.read(
    adminRepositoryProvider,
  );

  return repository.getProperties();
});

final adminUsersProvider =
    FutureProvider<List<AdminUserModel>>((ref) async {
  final repository = ref.read(
    adminRepositoryProvider,
  );

  return repository.getUsers();
});

final adminRentalRequestsProvider =
    FutureProvider<List<RentalRequestModel>>((ref) async {
  final repository = ref.read(
    adminRepositoryProvider,
  );

  return repository.getRentalRequests();
});

final adminLeasesProvider =
    FutureProvider<List<LeaseModel>>((ref) async {
  final repository = ref.read(
    adminRepositoryProvider,
  );

  return repository.getLeases();
});

final adminRentApiProvider = Provider<AdminRentApi>((ref) {
  return AdminRentApi(
    ref.read(apiClientProvider),
  );
});

final adminRentRepositoryProvider =
    Provider<AdminRentRepository>((ref) {
  return AdminRentRepository(
    ref.read(adminRentApiProvider),
  );
});

final adminRentChargesProvider =
    FutureProvider<List<AdminRentChargeModel>>((ref) async {
  final repository =
      ref.read(adminRentRepositoryProvider);

  return repository.getRentCharges();
});

final adminDashboardProvider =
    FutureProvider<AdminDashboardModel>((ref) async {
  final repository = ref.read(adminRepositoryProvider);

  return repository.getDashboardStatistics();
});