import '../models/rent_charge_model.dart';
import '../models/rent_payment_model.dart';
import 'rent_api.dart';

class RentRepository {
  final RentApi api;

  RentRepository(this.api);

  Future<List<RentChargeModel>> getOwnerRentCharges() {
    return api.getOwnerRentCharges();
  }

  Future<RentChargeModel> getRentCharge(String chargeId) {
    return api.getRentCharge(chargeId);
  }

  Future<RentPaymentModel?> getPaymentForCharge(
    String chargeId,
  ) {
    return api.getPaymentForCharge(chargeId);
  }

  Future<RentChargeModel> createRentCharge({
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

  Future<RentPaymentModel> recordPayment({
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