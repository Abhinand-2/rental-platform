import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/admin_rent_charge_model.dart';
import '../models/admin_rent_payment_model.dart';

class AdminRentApi {
  final ApiClient apiClient;

  AdminRentApi(this.apiClient);

  Future<List<AdminRentChargeModel>> getRentCharges() async {
    final response = await apiClient.dio.get(
      '/api/rent/charges/admin',
    );

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => AdminRentChargeModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<AdminRentChargeModel> createRentCharge({
    required String leaseId,
    required int billingYear,
    required int billingMonth,
    required double amount,
    required String dueDate,
  }) async {
    final response = await apiClient.dio.post(
      '/api/rent/charges',
      data: {
        'leaseId': leaseId,
        'billingYear': billingYear,
        'billingMonth': billingMonth,
        'amount': amount,
        'dueDate': dueDate,
      },
    );

    return AdminRentChargeModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<AdminRentPaymentModel?> getPaymentForCharge(
    String chargeId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/api/rent/payments/charge/$chargeId',
      );

      return AdminRentPaymentModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  Future<AdminRentPaymentModel> recordPayment({
    required String rentChargeId,
    required double amount,
    String? paymentReference,
  }) async {
    final response = await apiClient.dio.post(
      '/api/rent/payments',
      data: {
        'rentChargeId': rentChargeId,
        'amount': amount,
        'paymentReference': paymentReference,
      },
    );

    return AdminRentPaymentModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}