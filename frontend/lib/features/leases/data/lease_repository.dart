import '../models/lease_model.dart';
import 'lease_api.dart';

class LeaseRepository {
  final LeaseApi api;

  LeaseRepository(this.api);

  Future<List<LeaseModel>> getOwnerLeases() {
    return api.getOwnerLeases();
  }

  Future<LeaseModel> getLease(
    String leaseId,
  ) {
    return api.getLease(leaseId);
  }

  Future<LeaseModel> createLease({
    required String rentalRequestId,
    required String startDate,
    required String endDate,
    required double monthlyRent,
    double? securityDeposit,
  }) {
    return api.createLease(
      rentalRequestId: rentalRequestId,
      startDate: startDate,
      endDate: endDate,
      monthlyRent: monthlyRent,
      securityDeposit: securityDeposit,
    );
  }

  Future<LeaseModel> terminateLease(
    String leaseId,
  ) {
    return api.terminateLease(leaseId);
  }

  Future<LeaseModel> cancelLease(
    String leaseId,
  ) {
    return api.cancelLease(leaseId);
  }
}