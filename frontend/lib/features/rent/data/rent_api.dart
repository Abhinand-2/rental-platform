import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/rent_charge_model.dart';
import '../models/rent_payment_model.dart';

class RentApi {
  final ApiClient apiClient;

  RentApi(this.apiClient);

  Future<List<RentChargeModel>> getOwnerRentCharges() async {
    final response = await apiClient.dio.get(
      '/api/rent/charges/owner',
    );

    final data = response.data as List;

    return data
        .map(
          (json) => RentChargeModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<RentChargeModel> getRentCharge(
    String chargeId,
  ) async {
    final response = await apiClient.dio.get(
      '/api/rent/charges/$chargeId',
    );

    return RentChargeModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<RentPaymentModel?> getPaymentForCharge(
    String chargeId,
  ) async {
    try {
      final response = await apiClient.dio.get(
        '/api/rent/payments/charge/$chargeId',
      );

      return RentPaymentModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  Future<RentChargeModel> createRentCharge({
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

    return RentChargeModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<RentPaymentModel> recordPayment({
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

    return RentPaymentModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}