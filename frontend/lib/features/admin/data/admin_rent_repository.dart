import '../models/admin_rent_charge_model.dart';
import '../models/admin_rent_payment_model.dart';
import 'admin_rent_api.dart';

class AdminRentRepository {
  final AdminRentApi api;

  AdminRentRepository(this.api);

  Future<List<AdminRentChargeModel>> getRentCharges() {
    return api.getRentCharges();
  }

  Future<AdminRentChargeModel> createRentCharge({
    required String leaseId,
    required int billingYear,
    required int billingMonth,
    required double amount,
    required String dueDate,
  }) {
    return api.createRentCharge(
      leaseId: leaseId,
      billingYear: billingYear,
      billingMonth: billingMonth,
      amount: amount,
      dueDate: dueDate,
    );
  }

  Future<AdminRentPaymentModel?> getPaymentForCharge(
    String chargeId,
  ) {
    return api.getPaymentForCharge(chargeId);
  }

  Future<AdminRentPaymentModel> recordPayment({
    required String rentChargeId,
    required double amount,
    String? paymentReference,
  }) {
    return api.recordPayment(
      rentChargeId: rentChargeId,
      amount: amount,
      paymentReference: paymentReference,
    );
  }
}